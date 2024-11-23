import os
import subprocess
import sys
from datetime import datetime

def run_nmap(ip_range, output_dir):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = os.path.join(output_dir, f"nmap_scan_{timestamp}")
    xml_output = f"{output_file}.xml"
    
    print(f"Running nmap scan on {ip_range}...")
    try:
        subprocess.run([
            "nmap", "-sV", "-vv", "-oA", output_file, ip_range
        ], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running nmap: {e}")
        sys.exit(1)
    
    print(f"nmap scan complete. Outputs saved as {output_file}.*")
    return xml_output

def format_results_with_nmap_formatter(xml_file, output_dir):
    print(f"Formatting results with nmap-formatter for {xml_file}...")
    try:
        # Generate Markdown output
        md_output = os.path.join(output_dir, "nmap_results.md")
        subprocess.run([
            "nmap-formatter", "-f", "md", "-o", md_output, xml_file
        ], check=True)
        print(f"Markdown results saved as {md_output}")

        # Generate D2 output
        d2_output = os.path.join(output_dir, "nmap_results.d2")
        subprocess.run([
            "nmap-formatter", "-f", "d2", "-o", d2_output, xml_file
        ], check=True)
        print(f"D2 results saved as {d2_output}")

    except subprocess.CalledProcessError as e:
        print(f"Error formatting results: {e}")
        sys.exit(1)

def main():
    if len(sys.argv) < 3:
        print("Usage: python nmap-scan.py <IP_OR_RANGE> <OUTPUT_DIRECTORY>")
        sys.exit(1)
    
    ip_range = sys.argv[1]
    output_dir = sys.argv[2]

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    xml_file = run_nmap(ip_range, output_dir)
    format_results_with_nmap_formatter(xml_file, output_dir)

if __name__ == "__main__":
    main()
