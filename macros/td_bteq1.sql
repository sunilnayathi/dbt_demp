{% macro load_weather_data() %}

    {% do run_query("
        CREATE TEMP TABLE temp_weather AS
        SELECT
            *
        FROM DEMO.DEMO_SCHEMA.WEATHER
    ") %}

     {% do run_query("   DELETE FROM DEMO.DEMO_SCHEMA.WEATHER   ") %}

    {% do run_query("
        INSERT INTO DEMO.DEMO_SCHEMA.WEATHER
        (
            CITYNAME, LAT, LON, CLOUDS, HUMIDITY, PRESSURE, TEMP, TIME, WEATHER
        )
        SELECT
            CITYNAME, LAT, LON, CLOUDS, HUMIDITY, PRESSURE, TEMP, TIME, WEATHER
        FROM temp_weather
        GROUP BY CITYNAME, LAT, LON, CLOUDS, HUMIDITY, PRESSURE, TEMP, TIME, WEATHER
    ") %}

{% do run_query("
        COPY INTO @DEMO.DEMO_SCHEMA.S3_REPORT_EXTRACT/test.csv
            FROM (
                    SELECT CITYNAME, LAT, LON, CLOUDS, HUMIDITY, PRESSURE, TEMP, TIME, WEATHER
                    FROM DEMO.DEMO_SCHEMA.WEATHER
                    )
            FILE_FORMAT = (
                TYPE = CSV
                COMPRESSION = NONE
                )
            HEADER = TRUE
            SINGLE = TRUE
            OVERWRITE = TRUE
    ") %}

{% endmacro %}