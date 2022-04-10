##	Usage

###	Example

```yaml
      - uses: actions/checkout@v3
        with:
          persist-credentials: false
      - uses: julia-actions/setup-julia@v1
        with:
          show-versioninfo: true
      - uses: julia-actions/julia-buildpkg@v1
      - uses: julia-actions/julia-runtest@v1
      - uses: heptazhou/julia-codecov@v1
      - uses: codecov/codecov-action@v3
        with:
          file: lcov.info
```

###	Option

See [action.yml](action.yml).

