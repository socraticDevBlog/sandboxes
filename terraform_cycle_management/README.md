# Terraform: Best Practices and Anti-Patterns

## 1. Terraform as a Declarative Tool
Terraform lets you describe your desired infrastructure state. It figures out the steps to reach that state—no need to specify execution order.

## 2. Why Imperative Patterns Happen
Developers sometimes use imperative logic (like `depends_on`) out of habit, a desire for control, or lack of knowledge about Terraform’s features. This can lead to anti-patterns such as unnecessary dependencies or overuse of modules.

## 3. Modules: Use When Needed
Modules are for code reuse, not for every resource or loop. Prefer native constructs like `for_each` or `count` for repetitive logic.

## 4. Dependency Graphs

- **Recommended:** Resources are created in parallel, with no forced dependencies.
- **Anti-pattern:** Resources are chained with explicit dependencies, slowing down execution and complicating the graph.

## Why the `recommended/` Example Is More Idiomatic

- **Implicit dependencies:** Terraform infers order from references—no need for `depends_on`.
- **Native constructs:** Use `for_each` and locals for loops and data transformation.
- **Parallelism:** No artificial dependencies means faster applies.
- **Declarative clarity:** Focus on the desired end state, not the process.

**Summary:**  
Let Terraform manage dependencies through references. Use explicit dependencies only when absolutely necessary.

## How to Run

```sh
terraform init
terraform apply
terraform graph > graph_recommended.dot
```

---

For more details, see the full example files in the `recommended/` and `anti-pattern/` folders.
