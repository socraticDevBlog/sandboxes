# helm_sanity - trust no LLM

lately i've noticed LLM hallucinating Helm template configurations that just
doesn't work since the template doesn't handle their suggested value tweaks

Helm usual behavior is just ignoring unhandled values

Default Behavior: Helm ignores non-existing properties unless explicitly
disallowed in the schema (`values.schema.json`).

To Enforce Validation: Add "additionalProperties": false to the schema. This
may trigger false positive linting error since most Helm Chart allows and
manages properties that are not declared in the values schema

... and it becomes your problem to understand why your change haven't been
applied!

let's use native Helm cli to validate that your configurations will end up in
the applied manifests

## add bitnami repo to your machine

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update
```

## validate files

✅ when using valid values, expect to see the values in the compiled manifest

```bash
helm template my-nginx bitnami/nginx -f values_valid.yaml | grep -E 'foo|test'
```

expected output:

```
        foo: bar
        test: one
        test2: two
```

❌ when using unhandled values, expect they just silently won't get included in
the compiled manifest

```bash
helm template my-nginx bitnami/nginx -f values_invalid.yaml | grep -E 'solve_all_my_problems'
```

output:

```bash

```

## 🕵️ do your own research

The easiest way to figure out what values you can pass to your Helm template is
by either downloading the template's values to your computer or by visiting the
git repository where this template is stored

for bitnami/nginx

```bash
helm show values bitnami/nginx >> bitnami-nginx-all-values.yaml
```

or

<https://github.com/bitnami/charts/blob/main/bitnami/nginx/values.yaml>

## 🌸 nice commands

download the whole Helm chart to your local machine

```bash
helm pull bitnami/nginx --untar
```

download just the values

```bash
helm show values bitnami/nginx > default-values.yaml
```

## sources

<https://artifacthub.io/packages/helm/bitnami/nginx>
