{% macro safe_cast(column, type) %}
    case
        when {{ column }} is null then null
        when trim(cast({{ column }} as varchar)) = '' then null
        else cast({{ column }} as {{ type }})
    end
{% endmacro %}
