# helm_sanity - trust no LLM

Recently, I’ve noticed that LLMs often suggest Helm template configurations that don’t work because the templates don’t account for the proposed value changes.

By default, Helm ignores unhandled or non-existent properties unless explicitly disallowed in the schema (`values.schema.json`).

__Default Behavior:__ Helm will silently ignore properties that are not defined in the chart.

To Enforce Validation: Add `additionalProperties": false` to the schema. However, this may result in false-positive linting errors, as many Helm charts are designed to handle properties not explicitly declared in the schema.

This can leave you wondering why your changes weren’t applied!

Let’s use the native Helm CLI to validate that your configurations are correctly reflected in the rendered manifests.

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
