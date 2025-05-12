The `install_tools.sh` script in your repository is designed for setting up a complete development environment. Here's a summary of its functionality:

### Tools Installed:
1. **Node.js (via NVM)**:
   - Installs and configures NVM.
   - Retrieves and sets up the latest LTS version of Node.js.

2. **Java (via SDKMAN)**:
   - Installs SDKMAN and configures it.
   - Sets up multiple Java versions (`8.0.392-amzn`, `11.0.21-amzn`, `17.0.9-amzn`, `21.0.1-amzn`).
   - Allows easy switching between Java versions.

3. **Python (via pyenv)**:
   - Installs pyenv and its dependencies.
   - Retrieves and installs the latest Python version.
   - Configures the installed version as the default.

4. **Docker**:
   - Installs Docker and Docker Compose if not already installed.
   - Adds the current user to the `docker` group for permission management.
   - Provides guidance for activating group changes.

5. **Git**:
   - Installs Git if absent.
   - Checks the installed version against the latest release and provides update instructions if needed.

6. **IntelliJ IDEA (Community Edition)**:
   - Installs IntelliJ IDEA via Snap.
   - Checks the installed version and updates if necessary.

7. **Visual Studio Code**:
   - Installs VS Code via Snap.
   - Checks the installed version and updates if necessary.

8. **DBeaver (Community Edition)**:
   - Installs DBeaver via Snap.
   - Checks the installed version and updates if necessary.

9. **Postman**:
   - Installs Postman via Snap.
   - Checks the installed version and updates if necessary.

### Additional Features:
- **Environment Configuration**:
  - Adds environment variables for NVM, SDKMAN, and pyenv to `.bashrc` or `.zshrc`.
  - Sources the updated configuration files to apply changes immediately.

- **Version Checks**:
  - Retrieves latest versions of tools like Git, DBeaver, and Postman via API calls.
  - Compares installed versions with the latest and provides update instructions if needed.

- **Script Safety**:
  - Includes error handling and cleanup mechanisms.
  - Verifies `sudo` availability and permissions before proceeding.

- **Guidance for Users**:
  - Provides instructions for resolving common issues (e.g., Docker group changes).
  - Recommends a system reboot to ensure all changes take effect.

This script is comprehensive and automates the setup of a development environment with essential tools. It also ensures flexibility for version management and updates.
