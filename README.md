# SCSS Theme Structure and Compilation Guide

## Theme Structure
Below you can see the structure of the **theme** folder that contains all the SCSS files:

```
theme/
│
├── base/
│   ├── _reset.scss
│   └── _fonts.scss
│
├── abstracts/
│   ├── _variables.scss
│   ├── _functions.scss
│   ├── _mixins.scss
│   ├── _placeholders.scss
│   └── _animations.scss
│
├── components/
│   ├── _badges.scss
│   ├── _breadcrumb.scss
│   ├── _buttons.scss
│   ├── _dropdown.scss
│   ├── _facets.scss
│   ├── _forms.scss
│   ├── _pagination.scss
│   ├── _tables.scss
│   └── _tooltip.scss
│
├── layout/
│   ├── _header.scss
│   └── _footer.scss
│
├── pages/
│   ├── _home.scss
│   ├── _dataset.scss
│   └── _resource.scss
│
└── main.scss
```

## Compiling Styles

### Prerequisites

Install **NVM** (Node Version Manager) to manage different versions of **Node.js** on your local machine.

See the official [documentation](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) for installation instructions.

### Setup Process

1. From the project folder, run `nvm i` to install the required version of **Node.js** specified in the `.nvmrc` file.
2. Install project dependencies using **NPM** (Node Package Manager), which comes bundled with Node.js:
    ```sh
    npm ci
    ```
    This command performs a "clean install" using the `package-lock.json` file to ensure consistent dependency versions.

2. When you have it, write `nvm i` from the project folder, to install the required version of `node`. It's specified in the
`.nvmrc` file. 

### Compiling Commands

1. Development Mode:
    ```sh
    npm run dev
    ```
    This command enters watch mode, tracking changes to any SCSS file in the **theme** folder and includes source maps for debugging.

2. Production Build:
    ```sh
    npm run build
    ```
    This command creates minified style files for production. Run this when you're ready to deploy your changes.

