# Development Guidelines

## Overview

This document outlines the development standards and best practices for the JB Faturamento dbt project. Following these guidelines ensures code quality, maintainability, and consistency across the project.

## Code Standards

### SQL Formatting

- Use SQLFluff for consistent SQL formatting
- Follow the configured `.sqlfluff` rules
- Use lowercase for SQL keywords
- Use explicit table aliasing
- Limit line length to 80 characters

### Naming Conventions

#### Models

- **Staging**: `stg_<source_table>_<purpose>`
- **Intermediate**: `int_<business_concept>_<purpose>`
- **Marts**: `<business_concept>` (no prefix)

#### Columns

- Use snake_case for column names
- Use descriptive names that clearly indicate the data content
- Prefix date columns with `data_` when appropriate
- Use consistent naming across related models

#### Macros

- Use descriptive names that indicate the macro's purpose
- Use snake_case for macro names
- Prefix utility macros with `utils_` if applicable

### Model Structure

#### Staging Models

```sql
{{
    config(
        tags=['staging', '<domain>'],
        materialized='view'
    )
}}

select
    -- Primary keys and identifiers
    id,
    source_id,

    -- Business fields
    field_1,
    field_2,

    -- Metadata
    created_at,
    updated_at

from {{ source('SOURCE_SCHEMA', 'SOURCE_TABLE') }}
```

#### Intermediate Models

```sql
{{
    config(
        tags=['intermediate', '<domain>'],
        materialized='table'
    )
}}

with source_data as (
    select * from {{ ref('stg_source_table') }}
),

transformed_data as (
    select
        -- Business logic here
        *
    from source_data
)

select * from transformed_data
```

#### Mart Models

```sql
{{
    config(
        tags=['marts', '<domain>'],
        materialized='table'
    )
}}

select
    -- Final presentation layer
    *
from {{ ref('int_transformed_data') }}
```

## Documentation Standards

### Model Documentation

Every model should have:

- Clear description of the model's purpose
- Column descriptions for all fields
- Appropriate tags for organization
- Tests for data quality validation

Example:

```yaml
version: 2

models:
  - name: my_model
    description: "Clear description of what this model does"
    config:
      tags: ["domain", "purpose"]
    columns:
      - name: id
        description: "Primary key identifier"
        tests:
          - not_null
          - unique
```

### Source Documentation

All sources should include:

- Freshness checks
- Column-level tests
- Clear descriptions

## Testing Strategy

### Generic Tests

Apply these tests consistently:

- `not_null`: For required fields
- `unique`: For primary keys
- `relationships`: For foreign keys
- `accepted_values`: For enumerated fields

### Custom Tests

Create custom tests for:

- Business logic validation
- Data quality rules
- Cross-model consistency checks

### Test Naming

- Use descriptive names that indicate what is being tested
- Prefix with `assert_` for custom tests
- Include the business concept being tested

## Performance Considerations

### Materialization Strategy

- **Staging**: Views (for freshness and performance)
- **Intermediate**: Tables (for complex transformations)
- **Marts**: Tables (for end-user consumption)

### Incremental Processing

- Use incremental models for large tables
- Configure appropriate unique keys
- Set reasonable incremental predicates

### Optimization

- Use efficient join patterns
- Avoid unnecessary CTEs
- Consider clustering for large tables

## Development Workflow

### 1. Planning

Before starting development:

- Understand the business requirement
- Identify affected models and dependencies
- Plan the data flow and transformations
- Consider testing requirements

### 2. Development

During development:

- Follow naming conventions
- Add comprehensive documentation
- Include appropriate tests
- Use descriptive commit messages

### 3. Testing

Before submitting:

- Run `dbt test` to ensure all tests pass
- Run `dbt run` to verify model compilation
- Check model documentation with `dbt docs generate`
- Validate business logic manually

### 4. Code Review

Code review checklist:

- [ ] Model has proper documentation
- [ ] Tests are comprehensive and appropriate
- [ ] SQL follows formatting standards
- [ ] Performance considerations addressed
- [ ] Business logic is clear and well-commented
- [ ] Naming conventions followed

## Common Patterns

### Date Handling

```sql
-- Use consistent date formatting
cast(date_column as date) as formatted_date
```

### Null Handling

```sql
-- Use COALESCE for null handling
coalesce(field, 'default_value') as safe_field
```

### Conditional Logic

```sql
-- Use CASE statements for complex logic
case
    when condition_1 then result_1
    when condition_2 then result_2
    else default_result
end as calculated_field
```

### Incremental Logic

```sql
{{
    config(
        materialized='incremental',
        unique_key=['id', 'date'],
        incremental_strategy='merge'
    )
}}

select * from source_table
{% if is_incremental() %}
where date >= (select max(date) from {{ this }})
{% endif %}
```

## Troubleshooting

### Common Issues

1. **Model compilation errors**: Check syntax and dependencies
2. **Test failures**: Review data quality and business logic
3. **Performance issues**: Optimize queries and materialization
4. **Documentation issues**: Ensure YAML syntax is correct

### Debugging

- Use `dbt compile` to see compiled SQL
- Use `dbt show` to preview model results
- Check logs for detailed error messages
- Use `dbt debug` for configuration issues

## Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [SQLFluff Documentation](https://docs.sqlfluff.com/)
- [Project README](./README.md)

## Support

For questions or issues:

1. Check existing documentation
2. Review similar models in the project
3. Consult the data engineering team
4. Create an issue in the project repository
