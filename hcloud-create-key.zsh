#!/usr/bin/env zsh

public_key="$(stoml config.toml public_key)"
hcloud ssh-key create --name antimatter --public-key "$public_key"
