---
name: lazyvim-customization-research
description: 'Conduct comprehensive research on the architecture of LazyVim, including its core components, design patterns, and how it integrates with Neovim. Document your findings in a detailed report that can be used as a reference for users who want to make informed decisions about their own neovim setup which uses LazyVim.'
argument-hint: 'No arguments are required for this skill. Simply invoke it to start the research process.'
user-invocable: true
---

# LazyVim Customization Research
## Objective
Conduct comprehensive research on the architecture of the LazyVim neovim distro, including its core components and plugins, default options, autocommands, keybindings, and other configuration aspects which LazyVim provides by default upon install. You should also determine how these features can be customized or extended by users. Document your findings in a detailed report that can be used as a reference for other AI agents which will be responsible for implementing specific customizations or configurations based on the LazyVim architecture. The report should provide insights into how LazyVim is structured, how it integrates with Neovim, and how users can leverage its features to create a personalized Neovim setup that suits their specific needs and preferences. The goal is to empower users with the knowledge they need to make informed decisions about their own Neovim configuration when using LazyVim as a base.

## Research Areas
1. **LazyVim Architecture**: Analyze the overall architecture of LazyVim, including its core components, design patterns, and how it integrates with Neovim. Identify the key features and functionalities that LazyVim provides out of the box. This includes understanding the structure of the configuration files, how plugins are managed and loaded, and how LazyVim interacts with Neovim's core features.
2. **Customization Options**: Investigate the various ways users can customize their LazyVim setup. This includes exploring how to modify default options, add or remove plugins, change keybindings, and configure autocommands. Determine the best practices for customizing LazyVim while maintaining compatibility with future updates.
3. **Plugin Management**: Research how LazyVim manages plugins, including the use of the lazy.nvim plugin manager. Understand how plugins are defined, loaded, and configured within LazyVim. Identify any unique features or optimizations that LazyVim provides for plugin management and how users can leverage these features to enhance their Neovim experience.
4. **Keybindings and Autocommands**: Analyze the default keybindings and autocommands provided by LazyVim. Document how these can be customized or extended by users. Identify any common patterns or conventions used in LazyVim for defining keybindings and autocommands, and provide guidance on how users can create their own custom keybindings and autocommands that integrate seamlessly with the LazyVim architecture. This includes understanding how to override default keybindings and autocommands without causing conflicts or issues with the existing configuration.
5. **Extra's Section**: Explore the extras section of LazyVim, which includes additional plugins and configurations that are not part of the core setup but can be easily enabled by users. Document the available extras, their functionalities, and how they can be integrated into a user's Neovim setup and further customized. Provide insights into when and why users might want to enable certain extras based on their specific needs and preferences and how they can customize the functionality of said extras.
6. **Research Individual Plugins**: For each plugin included in the default installation of LazyVim, research its purpose, features, and how it is configured within LazyVim. Document any unique configurations or optimizations that LazyVim provides for these plugins and how users can further customize their behavior to suit their needs. This includes understanding how to enable or disable specific plugins, configure their options, and integrate them with other plugins or features within LazyVim. You should also document default options, autocommands, and keybindings etc. for individual plugins you research. This will help users understand how each plugin contributes to the overall functionality of LazyVim and how they can tailor their Neovim setup by customizing these plugins.
    - Do the same for plugins included in the extras section, documenting their functionalities and individual defaults.
7. **Best Practices and Recommendations**: Based on your research, provide best practices and recommendations for users who want to customize their LazyVim setup. This could include tips on how to maintain compatibility with future updates, how to avoid common pitfalls when customizing LazyVim, and how to leverage the features of LazyVim to create a personalized Neovim experience that suits their specific needs and preferences.

## Deliverables
- A comprehensive report detailing the findings from the research areas outlined above. The report should be well-structured, easy to understand, and include examples where applicable to illustrate key points about LazyVim's architecture and customization options and plugins and keybindings which are included in the default installation and the extras section. The report should serve as a valuable resource for users looking to customize their Neovim setup using a LazyVim base tailored to their specific needs in their Neovim configuration.

## Helpful Resources
- [LazyVim Documentation](https://www.lazyvim.org/)
- [LazyVim Starter Repository](https://github.com/LazyVim/starter)
- [LazyVim Project Repository](https://github.com/LazyVim/LazyVim)
- [lazy.nvim plugin manager documentation](https://github.com/folke/lazy.nvim)
- [Neovim official documentation](https://neovim.io/doc/user/)
