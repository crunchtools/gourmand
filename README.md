# gourmand container

Pre-built container image for [gourmand](https://gitlab.com/mattdm/gourmand), an AI-slop detector for codebases. Saves ~5 minutes of Rust compilation per CI run.

## Pull

```bash
podman pull quay.io/crunchtools/gourmand:1.0.0
```

Pin the tag. `:latest` currently serves the previous build (upstream `v0.1.0`)
while consumers migrate to `1.0.0` (upstream `v0.16.5`) -- see CHANGELOG.md.

## Usage

### Local

```bash
podman run --rm -v .:/workspace:Z quay.io/crunchtools/gourmand:1.0.0 check --full /workspace
```

### GitLab CI

```yaml
gourmand:
  stage: test
  image: quay.io/crunchtools/gourmand:1.0.0
  script:
    - gourmand check --full .
```

### GitHub Actions

```yaml
- name: Run gourmand
  run: |
    docker run --rm -v ${{ github.workspace }}:/workspace quay.io/crunchtools/gourmand:1.0.0 check --full /workspace
```

## GitHub Actions (crunchtools repos)

Do not copy the snippet above into a crunchtools repo. Use the reusable
workflow, which centralizes the image pin:

```yaml
jobs:
  gourmand:
    name: Code Quality (Gourmand)
    uses: crunchtools/gatehouse/.github/workflows/gourmand.yml@v0.6.0
```

## License

Container build infrastructure is AGPL-3.0-or-later. Gourmand itself is licensed under its upstream terms.
