# gourmand container

Pre-built container image for [gourmand](https://codeberg.org/mattdm/gourmand), an AI-slop detector for codebases. Saves ~5 minutes of Rust compilation per CI run.

## Pull

```bash
podman pull quay.io/crunchtools/gourmand
```

## Usage

### Local

```bash
podman run --rm -v .:/workspace:Z quay.io/crunchtools/gourmand --full /workspace
```

### GitLab CI

```yaml
gourmand:
  stage: test
  image: quay.io/crunchtools/gourmand
  script:
    - gourmand --full .
```

### GitHub Actions

```yaml
- name: Run gourmand
  run: |
    docker run --rm -v ${{ github.workspace }}:/workspace quay.io/crunchtools/gourmand --full /workspace
```

## License

Container build infrastructure is AGPL-3.0-or-later. Gourmand itself is licensed under its upstream terms.
