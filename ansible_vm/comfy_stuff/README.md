# Leisure Playbook

This playbook sets up leisure tools and a modern terminal environment on your Debian 12 VM. It installs:
- weechat IRC client
- zsh and oh-my-zsh
- powerlevel10k theme
- powerline and FiraCode fonts
- vim-plug and basic Vim plugins (configurable)

## Usage

From the project root, run:

```sh
ansible-playbook -i ../inventory comfy_stuff/playbook.yml
```

## Customizing Vim Plugins

You can override the default Vim plugins by passing the `vim_plugins` variable:

```sh
ansible-playbook -i ../inventory comfy_stuff/playbook.yml -e '{"vim_plugins": ["tpope/vim-sensible", "preservim/nerdtree", "junegunn/fzf.vim"]}'
```

## Notes
- The playbook will set zsh as the default shell for the Ansible user.
- User-level tasks (oh-my-zsh, powerlevel10k, vim-plug) are run as the target user, not root.
- The playbook is idempotent and safe to re-run.
