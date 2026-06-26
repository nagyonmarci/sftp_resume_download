# SFTP Resume Download Script

A bash script for resuming interrupted SFTP downloads with automatic retry functionality.

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
```
brew install expect
```

**Ubuntu/Debian:**
```
sudo apt-get install expect
```

**CentOS/RHEL:**
```
sudo yum install expect
```

## Usage

```
./sftp_resume_download.sh <user@server> <remote_file> [local_dest]
```

**Examples:**
```
./sftp_resume_download.sh admin@backup.example.com /data/dump.tar.gz
./sftp_resume_download.sh admin@backup.example.com /data/dump.tar.gz ~/downloads/dump.tar.gz
```

Enter your password when prompted.

## How It Works

1. **Connect to SFTP server** and retrieve file listing for the specified file
2. **Extract remote file size** using regex pattern matching
3. **Check local file size** (if file exists)
4. **Compare sizes** and resume download if needed
5. **Retry automatically** up to 10 times if connection fails

## Example Output

```
Password:
📦 Remote file size: 22537972343 bytes
💾 Local file size: 11268986171 bytes
🔄 Resuming download (1/10)...
filename.tar.gz  50% 11GB 8.0MB/s 21:30 ETA
```

## File Structure

The script expects the SFTP `ls -l` output in this format:

```
-rw-r--r-- 1 user group 22537972343 May 26 08:32 filename.tar.gz
```

## Error Handling

- **Connection failures**: Automatic retry (up to 10 attempts, 2s between retries)
- **Invalid file sizes**: Script exits with error message
- **Missing files**: Starts download from beginning
- **Permission issues**: Clear error messages

## Compatibility

- **macOS**: Uses `stat -f%z` for file size
- **Linux**: Uses `stat -c%s` for file size (automatic detection)

## Security Notes

- Password is not stored or logged, no credentials are saved to disk
- Uses secure SFTP protocol
- Password is passed to `expect` via environment variable — safe against shell injection even with special characters (`$`, backticks, quotes)
- Host key verification: new hosts are automatically added to `known_hosts` on first connect; changed keys cause an error (MITM protection)

## Troubleshooting

**"Failed to retrieve remote file size"**
- Check server connection
- Verify file exists on server
- Ensure correct permissions

**"expect: command not found"**
- Install expect package (see Prerequisites)

**Permission denied**
- Check file permissions: `chmod +x sftp_resume_download.sh`
- Verify SFTP server credentials

**Script hangs or "Bad packet length" error**
- Do not pipe the script through `tee` (e.g. `script | tee file`) — it corrupts expect's pty allocation and breaks the SSH connection
- Run the script directly; monitor download progress by checking the local file size separately

### Debug Mode

Add debug output by modifying the expect timeout:
```
set timeout 20
set debug 1
```

## License

MIT License
