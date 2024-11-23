import os
import subprocess
import sys
from datetime import datetime

def sanitize_filename(filename):
    """Sanitize the filename by replacing special characters."""
    return filename.replace("/", "_").replace(":", "_")

def run_nmap(ip_range, output_dir):
    sanitized_ip_range = sanitize_filename(ip_range)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = os.path.join(output_dir, f"nmap_scan_{sanitized_ip_range}_{timestamp}")
    xml_output = f"{output_file}.xml"
    
    print(f"Running nmap scan on {ip_range}...")
    try:
        subprocess.run([
            "nmap", "-vv", "-A", "-oA", output_file, ip_range
        ], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running nmap: {e}")
        sys.exit(1)
    
    print(f"nmap scan complete. Outputs saved as {output_file}.*")
    return xml_output

def format_results_with_nmap_formatter(xml_file, output_dir, ip_range):
    sanitized_ip_range = sanitize_filename(ip_range)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    print(f"Formatting results with nmap-formatter for {xml_file}...")
    try:
        # Generate Markdown output with IP and timestamp
        md_output = os.path.join(output_dir, f"nmap_results_{sanitized_ip_range}_{timestamp}.md")
        subprocess.run([
            "nmap-formatter", "md", "-f", md_output, xml_file
        ], check=True)
        print(f"Markdown results saved as {md_output}")

        # Generate D2 output with IP and timestamp
        d2_output = os.path.join(output_dir, f"nmap_results_{sanitized_ip_range}_{timestamp}.d2")
        subprocess.run([
            "nmap-formatter", "d2", "-f", d2_output, xml_file
        ], check=True)
        print(f"D2 results saved as {d2_output}")

        # Render D2 output to PNG
        png_file = os.path.join(output_dir, os.path.splitext(os.path.basename(d2_output))[0] + ".png")
        print(f"Rendering D2 file {d2_output} to PNG...")
        subprocess.run([
            "d2", d2_output, png_file
        ], check=True)
        print(f"PNG image saved as {png_file}")

    except subprocess.CalledProcessError as e:
        print(f"Error formatting results: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) < 3:
        print("Usage: python nmap_scan.py <IP_OR_RANGE> <OUTPUT_DIRECTORY>")
        sys.exit(1)
    
    ip_range = sys.argv[1]
    output_dir = sys.argv[2]

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    xml_file = run_nmap(ip_range, output_dir)
    format_results_with_nmap_formatter(xml_file, output_dir, ip_range)

if __name__ == "__main__":
    main()
