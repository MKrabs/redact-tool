# Redact Tool

A flexible, profile-based text redaction tool for sanitizing sensitive information in files. Perfect for sharing logs, documents, or code snippets without exposing confidential data.

## Features

✨ **Profile-Based Redaction** - Create and manage multiple redaction profiles for different use cases  
🔄 **Flexible Replacements** - Define custom find-and-replace patterns  
📝 **Multiple Output Modes** - Auto-generate filenames, overwrite, or specify custom output  
📊 **Replacement Logging** - Track what was redacted with detailed statistics  
🎨 **Colorized Output** - Easy-to-read colored terminal output  
⚡ **Shell Completion** - Bash completion support for faster workflows  

## Installation

### Quick Install

```bash
sudo bash install.sh
```

This will:
- Install the `redact` command to `/usr/local/bin/`
- Copy library files to `/usr/local/share/redact/`
- Create a default profile in `~/.config/redact/profiles/default/`

### Uninstall

```bash
sudo bash uninstall_redact.sh
```

Note: User profiles in `~/.config/redact/` are preserved during uninstallation.

## Quick Start

### Basic Usage

```bash
# Redact a file using the default profile
redact myfile.txt

# Output: myfile_redacted.txt
```

### Specify Output File

```bash
redact myfile.txt -o sanitized.txt
```

### View Replacement Statistics

```bash
redact myfile.txt --log
```

Output:
```
Redacted → myfile_redacted.txt
Replacement log:
    3x username
    2x api_key
    1x secret_token
```

## Profile Management

### List Profiles

```bash
redact --list profile
```

### Create a New Profile

```bash
redact --profile-new work
```

This creates a new profile at `~/.config/redact/profiles/work/` with:
- `config.ini` - Profile configuration
- `replacements.txt` - Replacement patterns

### Set Active Profile

```bash
redact --profile-set work
```

### Use Profile for Single Run

```bash
redact myfile.txt --profile work
```

### Edit Replacement Patterns

```bash
redact --edit-replacements work
```

Or manually edit:
```bash
nano ~/.config/redact/profiles/work/replacements.txt
```

### Disable/Enable Profiles

```bash
redact --profile-disable work
redact --profile-enable work
```

### Delete Profile

```bash
redact --profile-delete work
```

## Replacement Patterns

Replacement patterns are defined in `replacements.txt` with simple `find = replace` syntax:

```ini
# Comments are supported
my_username = user1
SecretCompany = company1
192.168.1.100 = 10.0.0.1
api_key_abc123 = REDACTED_API_KEY
/home/john = /home/user
```

### View Current Replacements

```bash
redact --list replacements
```

## Advanced Usage

### Add Additional Replacement Files

```bash
redact myfile.txt --add /path/to/extra-replacements.txt
```

### Multiple Output Modes

Edit `~/.config/redact/profiles/default/config.ini`:

```ini
# Auto mode: adds _redacted before extension
output_mode=auto

# Overwrite mode: replaces original file
output_mode=overwrite

# Custom mode: uses specified name
output_mode=custom
custom_output_name=sanitized_output.txt

# Additional replacement files (semicolon-separated)
additional_replacement_files=/path/to/file1.txt;/path/to/file2.txt

# Enable colored output
color=true
```

## Use Cases

### Sanitize Development Logs

```bash
# Create a profile for log sanitization
redact --profile-new logs

# Edit replacements
redact --edit-replacements logs
```

Add patterns:
```ini
/home/developer = /home/user
real-server.company.com = example.com
db_password_xyz = REDACTED_PASSWORD
```

### Share Code with Redacted Paths

```bash
redact --profile-new code-share
```

Replacements:
```ini
/Users/myname = /Users/user
MyCompanyName = CompanyX
proprietary_lib = external_lib
```

### Multiple File Processing

```bash
for file in *.log; do
    redact "$file" --profile logs --log
done
```

## Configuration Files

### Profile Structure

```
~/.config/redact/
├── global.ini                    # Global settings
└── profiles/
    ├── default/
    │   ├── config.ini           # Profile config
    │   └── replacements.txt     # Find/replace patterns
    └── work/
        ├── config.ini
        └── replacements.txt
```

### Global Configuration

`~/.config/redact/global.ini`:
```ini
active_profile=default
```

## Command Reference

### Profile Management Commands

| Command | Description |
|---------|-------------|
| `--profile-new NAME` | Create a new profile |
| `--profile-set NAME` | Set the active profile |
| `--profile-disable NAME` | Disable a profile |
| `--profile-enable NAME` | Enable a disabled profile |
| `--profile-delete NAME` | Delete a profile |
| `--edit-replacements [NAME]` | Edit replacement patterns |
| `--list [profile\|replacements]` | List profiles or replacements |

### Run Options

| Option | Short | Description |
|--------|-------|-------------|
| `--profile NAME` | `-p` | Use specific profile for this run |
| `--output FILE` | `-o` | Specify output filename |
| `--add FILE` | `-a` | Add extra replacement file |
| `--log` | | Print replacement statistics |
| `--help` | | Show help message |

## Shell Completion

Bash completion is automatically available after installation:

```bash
redact --profile-<TAB>    # Shows: --profile-set, --profile-new, etc.
redact --profile <TAB>    # Shows available profiles
redact --list <TAB>       # Shows: profile, replacements
```

## Tips & Best Practices

1. **Test First**: Always verify redaction on a copy before processing important files
2. **Use Specific Patterns**: Avoid overly broad patterns that might redact too much
3. **Multiple Profiles**: Create separate profiles for different contexts (work, personal, etc.)
4. **Review Output**: Check `--log` output to ensure expected replacements occurred
5. **Backup Originals**: Keep originals safe when using `output_mode=overwrite`
6. **Case Sensitivity**: Patterns are case-sensitive by default

## Examples

### Example 1: Sanitize Application Logs

```bash
# Create profile
redact --profile-new app-logs

# Add patterns
cat >> ~/.config/redact/profiles/app-logs/replacements.txt <<EOF
user@example.com = user@domain.com
192.168.1.50 = 10.0.0.1
secret_key_12345 = REDACTED_KEY
EOF

# Use it
redact application.log --profile app-logs --log
```

### Example 2: Quick One-Time Redaction

```bash
# Create temporary replacement file
cat > /tmp/temp-redact.txt <<EOF
Alice = Person1
Bob = Person2
EOF

# Use with default profile
redact transcript.txt --add /tmp/temp-redact.txt -o public.txt
```

### Example 3: Batch Processing

```bash
#!/bin/bash
# Redact all markdown files in a directory

for md in *.md; do
    echo "Processing $md..."
    redact "$md" --profile documentation --log
done
```

## Troubleshooting

### "Command not found: redact"

Ensure `/usr/local/bin` is in your PATH:
```bash
echo $PATH | grep /usr/local/bin
```

If not, add to `~/.bashrc`:
```bash
export PATH="/usr/local/bin:$PATH"
```

### Permission Denied During Installation

The installer requires sudo privileges:
```bash
sudo bash install.sh
```

### Profile Config Not Loading

Ensure profile structure is correct:
```bash
ls -la ~/.config/redact/profiles/default/
# Should show: config.ini and replacements.txt
```

### No Replacements Happening

1. Check your replacement patterns:
   ```bash
   redact --list replacements
   ```

2. Verify the active profile:
   ```bash
   redact --list profile
   ```

3. Test with `--log` flag to see what's being replaced

## Requirements

- Bash 4.0 or later
- Standard Unix utilities: `sed`, `grep`, `cp`
- sudo access for installation

## License

See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Changelog

### Version 1.0.0 (November 2025)
- Initial release
- Profile-based redaction system
- Multiple output modes
- Shell completion support
- Replacement logging
- Colorized output

---

**Made with ❤️ for privacy-conscious developers**

