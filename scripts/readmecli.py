import re
import os
import subprocess
import yaml
import logging


def list_directories(base_path):
    """List all directories in the given base path"""
    return [d for d in os.listdir(base_path) if os.path.isdir(os.path.join(base_path, d))]


def read_yaml_file(file_path):
    """Read a YAML file and return the content"""
    try:
        with open(file_path, 'r') as file:
            return yaml.safe_load(file)
    except Exception as e:
        logging.error(f"Failed to read {file_path}: {e}")
        return None


def render_helm_chart(chart_path, values_path):
    """Render Helm chart templates using provided values file"""
    try:
        # Make sure Helm is installed and chart_path/values_path are correct
        command = f"helm template my-release {chart_path} --values {values_path}"
        rendered_templates = subprocess.check_output(command, shell=True)
        return rendered_templates.decode('utf-8')
    except subprocess.CalledProcessError as e:
        logging.error(f"Helm template rendering failed: {e}")
        return None


def find_entry_command(rendered_yaml_content):
    """Find the entry command in the rendered deployment or statefulset"""
    command_pattern = re.compile(r'command:\s*\[(.*?)\]', re.DOTALL)

    # Using regex to find the command list or string
    matches = command_pattern.findall(rendered_yaml_content)
    if matches:
        logging.info(f"Found command: {matches[0]}")
        # Clean and split the command string into a list
        commands = matches[0].strip().split(',')
        # Remove quotes and extra whitespace
        commands = [cmd.strip().strip("'\"") for cmd in commands]
        return ' '.join(commands)
    return None


def run_docker_help(image_repository, image_tag, entry_command):
    """Run docker image with the entry command and --help"""
    try:
        # Include the entry command if available
        command = f"docker run --entrypoint {entry_command} --rm {image_repository}:{image_tag} --help"
        output = subprocess.check_output(
            command, stderr=subprocess.STDOUT, shell=True)
        return output.decode('utf-8')
    except subprocess.CalledProcessError as e:
        logging.error(f"Failed to run docker image: {e}")
        # Return the stderr output if command fails
        return e.output.decode('utf-8')


def format_cli_help_to_markdown(cli_output):
    # Split the output into lines
    lines = cli_output.split('\n')

    # Prepare to collect command configurations
    configs = []

    # Variables to keep track of the current command being processed
    current_command = None
    current_description = []
    current_default = None

    for line in lines:
        # Check for a line with a command
        command_match = re.match(r'\s*--([\w.-]+)\s+(.*)', line)

        if command_match:
            # If there's a current command, save it before starting a new one
            if current_command:
                configs.append({
                    'name': f'`{current_command}`',
                    'description': ' '.join(current_description).strip(),
                    'default': f'`{current_default}`' if current_default else None
                })

            # Reset the current command info
            current_command, rest_of_line = command_match.groups()
            current_description = [rest_of_line]
            current_default = None

            # Check for a default value in the rest of the line
            default_match = re.search(
                r'\(default\s+["\']?(.+?)["\']?\)$', rest_of_line)
            if default_match:
                current_default = default_match.group(1)
                current_description[-1] = current_description[-1].replace(
                    default_match.group(0), '').strip()

        elif current_command and (line.startswith('      ') or not line.strip()):
            # This is a continuation of the description of the current command
            current_description.append(line.strip())

    # Add the last command if there was one being processed
    if current_command:
        configs.append({
            'name': f'`{current_command}`',
            'description': ' '.join(current_description).strip(),
            'default': f'`{current_default}`' if current_default else None
        })

    return configs


def update_readme(readme_path, configs):
    try:
        with open(readme_path, 'r+') as readme:
            content = readme.read()
            start_marker = '## Configuration Options'
            intro = 'The following table lists the exhaustive configurable parameters that can be applied as part of the configmap (nested under `configmap.data`) or as standalone cli flags.'
            end_marker = '##'
            start = content.find(start_marker)
            end = content.find(end_marker, start + len(start_marker))

            # Create table markdown text
            table = "Option | Description | Default\n--- | --- | ---\n"
            for config in configs:
                row = f"{config['name']} | {config['description']} | {config['default'] or 'None'}\n"
                table += row

            config_data = f'{start_marker}\n{intro}\n\n{table}\n'

            if start == -1:
                content += config_data
            else:
                if end == -1:  # No end marker found, assume end of file
                    end = len(content)
                content = content[:start] + config_data + content[end:]

            readme.seek(0)
            readme.write(content)
            readme.truncate()  # Remove any remaining old content after the new content
    except Exception as e:
        logging.error(f"Failed to update README.md: {e}")
    """Update README.md with configuration data"""


def main():
    logging.basicConfig(level=logging.INFO)
    charts_dir = "../charts"  # Adjust this to your charts directory path

    for directory in list_directories(charts_dir):
        chart_path = os.path.join(charts_dir, directory)
        chart_yaml = read_yaml_file(os.path.join(chart_path, "Chart.yaml"))
        values_yaml = read_yaml_file(os.path.join(chart_path, "Values.yaml"))

        if chart_yaml and values_yaml:
            image_repository = values_yaml.get("image", {}).get("repository")
            image_tag = values_yaml.get("image", {}).get("tag")
            app_version = chart_yaml.get("appVersion")

            if image_tag:
                app_version = image_tag

            if image_repository and app_version:
                logging.info(f"Processing {image_repository}:{app_version}")
                rendered_templates = render_helm_chart(
                    chart_path, os.path.join(chart_path, "values.yaml"))

                if rendered_templates:
                    entry_command = find_entry_command(rendered_templates)
                    help_output = run_docker_help(
                        image_repository, app_version, entry_command)

                    if help_output:
                        config_data = format_cli_help_to_markdown(help_output)
                        update_readme(os.path.join(
                            chart_path, "README.md"), config_data)
                    else:
                        logging.warning(
                            f"Failed to run docker image: {image_repository}:{app_version}")
                else:
                    logging.warning(
                        f"Failed to render Helm chart: {chart_path}")


if __name__ == "__main__":
    main()
