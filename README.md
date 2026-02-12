# Word Document Tagging Add-In

A Microsoft Word add-in that enables AI-powered document tagging for accounting workflows. This add-in allows users to tag specific text selections within Word documents using Content Controls, making it easier to identify and categorize important document sections such as Revenue, Expenses, Risk, and other accounting-related content.

## Overview

This Office.js-based add-in provides a taskpane interface for Word that allows users to:
- Select text within a document
- Apply category tags to selections
- View all tagged regions in the document
- Manage and remove tags as needed
- Extract OOXML for inspection and debugging

The add-in uses Word's Content Controls API to wrap tagged text, preserving formatting while adding metadata that can be retrieved and managed programmatically.

## Features

### Current Features
- **Tag Selection Interface**: Dropdown menu with predefined tags (Revenue, Expenses, Risk, Other)
- **Content Control Wrapping**: Selected text is wrapped in Content Controls with associated metadata
- **Visual Styling**: Tagged regions are visually distinct for easy identification

### Planned Features (See Roadmap)
- List all tagged regions in the taskpane
- Navigate to tagged regions by clicking in the list
- Remove tags while preserving underlying text
- OOXML extraction and inspection tools
- Enhanced UI polish and user experience improvements

## Technology Stack

- **Framework**: React 18 with TypeScript
- **UI Components**: Fluent UI React Components
- **Build Tool**: Webpack 5
- **Office Platform**: Office.js (Word API)
- **Development**: Office Add-in CLI tools
- **Code Quality**: ESLint, Prettier, Babel

## Prerequisites

- Node.js (latest LTS version recommended)
- Microsoft Word (Desktop or Web)
- Microsoft 365 account (for testing)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/mitchcamza/word-doc-tagging-addin.git
   cd word-doc-tagging-addin
   ```

2. Install dependencies:
   ```bash
   cd add-in
   npm install
   ```

3. Install development certificates (first time only):
   ```bash
   npx office-addin-dev-certs install
   ```

## Usage

### Development Mode

1. Start the development server:
   ```bash
   npm run dev-server
   ```

2. In a separate terminal, start the add-in in Word:
   ```bash
   npm start
   ```

3. Word will open with the add-in loaded. Click "Show Taskpane" in the Home ribbon to open the add-in taskpane.

### Building for Production

```bash
npm run build
```

### Other Commands

- **Lint code**: `npm run lint`
- **Fix lint issues**: `npm run lint:fix`
- **Format code**: `npm run prettier`
- **Validate manifest**: `npm run validate`
- **Stop debugging**: `npm stop`

## Development Roadmap

The project is organized into four milestones:

### M1 - Add-in scaffold + running in Word ✓
- Office.js Word taskpane add-in setup
- Basic UI with tag dropdown and apply button
- Add-in running in Word Desktop

### M2 - Tag selection (Content Controls + metadata)
- Read current text selection
- Wrap selection in Content Controls
- Store tag metadata on Content Controls
- Preserve text formatting

### M3 - UI polish + list/remove tags
- Visual styling for tagged regions
- List all tagged Content Controls in taskpane
- Navigate to tagged regions
- Remove tags (delete Content Control wrapper)

### M4 - OOXML inspection + docs
- Extract and display OOXML for inspection
- Complete README with screenshots and demo GIF
- Final documentation and polish

## Project Structure

```
word-doc-tagging-addin/
├── add-in/                 # Main add-in application
│   ├── src/               # Source code
│   │   ├── taskpane/      # Taskpane UI components
│   │   └── commands/      # Command handlers
│   ├── assets/            # Icons and images
│   ├── manifest.xml       # Add-in manifest
│   ├── package.json       # Dependencies and scripts
│   └── webpack.config.js  # Build configuration
├── scripts/               # Utility scripts
├── issues.json           # Project planning and issues
└── README.md             # This file
```

## Contributing

This is a personal project currently under active development. Contributions, suggestions, and feedback are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Mitch Campbell**

## Acknowledgments

- Built with [Office.js](https://docs.microsoft.com/en-us/office/dev/add-ins/)
- UI powered by [Fluent UI](https://react.fluentui.dev/)
- Scaffolded with Office Add-in CLI tools

---

**Note**: This is an initial README that will be updated with screenshots, detailed usage instructions, and demo materials upon completion of Milestone 4.