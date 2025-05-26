# SFTP Resume Download Script

A robust bash script for resuming interrupted SFTP downloads with automatic retry functionality.

## Features

- **Resume Downloads**: Automatically continues interrupted downloads from where they left off
- **Size Verification**: Compares local and remote file sizes to ensure complete downloads
- **Auto Retry**: Attempts up to 10 reconnections if download fails
- **Password Security**: Prompts for password without displaying it on screen
- **Cross-Platform**: Works on macOS and Linux systems

## Prerequisites

- `expect` package installed
- `sftp` client available
- Bash shell

### Installing expect

**macOS (Homebrew):**

brew install expect


**Ubuntu/Debian:**

sudo apt-get install expect


**CentOS/RHEL:**

sudo yum install expect


## Configuration

Edit the script variables at the top of the file:

SERVER="your.ftp.server.com"

USER="your_username"

FILENAME="your_file.tar.gz"

MAX_TRY=10


## Usage

1. Make the script executable:

chmod +x sftp_resume_download.sh


2. Run the script:

./sftp_resume_download.sh


3. Enter your password when prompted

## How It Works

1. **Connect to SFTP server** and retrieve file listing
2. **Extract remote file size** using regex pattern matching
3. **Check local file size** (if file exists)
4. **Compare sizes** and resume download if needed
5. **Retry automatically** up to MAX_TRY times if connection fails

## Example Output

Password:

Remote file size: 22537972343 bytes

Local file size: 11268986171 bytes

Resuming download (1/10)...

filename.tar.gz 50% 11GB 8.0MB/s 21:30 ETA


## File Structure

The script expects the SFTP `ls -l` output in this format:

-rw-r--r-- 1 user group 22537972343 May 26 08:32 filename.tar.gz


## Error Handling

- **Connection failures**: Automatic retry with exponential backoff
- **Invalid file sizes**: Script exits with error message
- **Missing files**: Starts download from beginning
- **Permission issues**: Clear error messages

## Compatibility

- **macOS**: Uses `stat -f%z` for file size
- **Linux**: Modify to use `stat -c %s` for file size

## Security Notes

- Password is not stored or logged
- Uses secure SFTP protocol
- No credentials are saved to disk

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Troubleshooting

### Common Issues

**"Failed to retrieve remote file size"**
- Check server connection
- Verify file exists on server
- Ensure correct permissions

**"expect: command not found"**
- Install expect package (see Prerequisites)

**Permission denied**
- Check file permissions: `chmod +x sftp_resume_download.sh`

- Verify SFTP server credentials

### Debug Mode

Add debug output by modifying the expect timeout:
set timeout 20
set debug 1


## Author

Created for reliable large file transfers over SFTP with resume capability.

---

**Note**: Always test with small files first to ensure proper configuration.
