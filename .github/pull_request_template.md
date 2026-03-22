## Summary

<!-- What does this PR do and why? Link to issues, plans, or tickets if helpful. -->

## Type of change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation only
- [ ] Chore / tooling

## Test plan

<!-- How you verified the change locally. CI runs the checks below on every PR. -->

- [ ] `bin/brakeman --no-pager`
- [ ] `bin/bundler-audit`
- [ ] `bin/rubocop`
- [ ] `RAILS_ENV=test DATABASE_URL=postgres://postgres:postgres@localhost:5432 bin/rails db:test:prepare test` (or your local test DB URL)

## Checklist

- [ ] Self-review: naming, edge cases, and error handling look reasonable
- [ ] Migrations included if the schema changed (and are reversible or documented)
- [ ] API or feature docs updated if behavior or contracts changed
- [ ] No secrets or credentials committed

## Notes for reviewers

<!-- Optional: context, trade-offs, or areas you want extra eyes on. -->
