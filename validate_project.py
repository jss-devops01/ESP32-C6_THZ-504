#!/usr/bin/env python3
"""
Simple validation script for ESP32-C6 THZ-504 project
Checks basic file structure and YAML syntax compatibility
"""

import os
import sys
import yaml
import re

def check_file_exists(filepath, description):
    """Check if a file exists"""
    if os.path.exists(filepath):
        print(f"✓ {description}: {filepath}")
        return True
    else:
        print(f"✗ {description}: {filepath} - NOT FOUND")
        return False

def check_yaml_structure(filepath):
    """Check YAML file structure (ignoring ESPHome-specific tags)"""
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Replace ESPHome-specific tags with placeholders
        content = re.sub(r'!secret\s+\S+', '"SECRET_PLACEHOLDER"', content)
        content = re.sub(r'!extend\s+\S+', '"EXTEND_PLACEHOLDER"', content)
        content = re.sub(r'!include\s+.*', '"INCLUDE_PLACEHOLDER"', content)
        
        yaml.safe_load(content)
        print(f"✓ YAML structure valid: {filepath}")
        return True
    except Exception as e:
        print(f"✗ YAML structure invalid: {filepath} - {str(e)}")
        return False

def main():
    """Main validation function"""
    print("ESP32-C6 THZ-504 Project Validation")
    print("=" * 40)
    
    success = True
    
    # Check main files
    files_to_check = [
        ("esp32-c6-thz504.yaml", "Main configuration file"),
        ("README.md", "Documentation"),
        ("LICENSE", "License file"),
        (".gitignore", "Git ignore file"),
        ("secrets.yaml.template", "Secrets template"),
    ]
    
    for filepath, description in files_to_check:
        if not check_file_exists(filepath, description):
            success = False
    
    # Check source files
    src_files = [
        "src/property.h",
        "src/property.cpp", 
        "src/type.h",
        "src/type.cpp",
        "src/simple_variant.h",
        "src/communication.h",
        "src/communication.cpp",
        "src/callback_handler.h",
        "src/mapper.h",
        "src/mapper.cpp"
    ]
    
    for filepath in src_files:
        if not check_file_exists(filepath, f"Source file"):
            success = False
    
    # Check YAML files
    yaml_files = [
        "esp32-c6-thz504.yaml",
        "yaml/common.yaml",
        "yaml/thz504.yaml",
        "yaml/wp_base.yaml",
        "yaml/wp_binary.yaml",
        "yaml/wp_generic.yaml",
        "yaml/wp_number.yaml",
        "yaml/wp_switch.yaml",
        "yaml/wp_temperature.yaml",
        "yaml/wp_temperature_writable.yaml"
    ]
    
    print("\nValidating YAML structures...")
    for filepath in yaml_files:
        if os.path.exists(filepath):
            if not check_yaml_structure(filepath):
                success = False
    
    print("\n" + "=" * 40)
    if success:
        print("✓ All validations passed!")
        print("\nNext steps:")
        print("1. Copy secrets.yaml.template to secrets.yaml and fill in your values")
        print("2. Upload to your ESP32-C6 using: esphome run esp32-c6-thz504.yaml")
        return 0
    else:
        print("✗ Some validations failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())