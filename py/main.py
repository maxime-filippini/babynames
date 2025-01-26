import os
import pathlib
import polars as pl


def process_raw_file(path: pathlib.Path) -> pl.DataFrame:
    return pl.read_csv(path, separator="\t").select(
        pl.col("Rank").alias("rank"),
        pl.col("Female").alias("name"),
        pl.col("PctFemale")
        .str.replace("%", "")
        .cast(pl.Float64)
        .truediv(100)
        .alias("pct"),
    )


def process_year_file(year: int) -> None:
    process_raw_file(f"data/raw_{year}").with_columns(
        pl.lit(year).alias("year")
    ).write_json(f"data/processed_{year}.json")


def write_to_db(year: int) -> None:
    uri = os.environ["DATABASE_URL"].replace("postgres://", "postgresql://")
    df = pl.read_json(f"data/processed_{year}.json")
    df.write_database("baby_names", uri, if_table_exists="replace")


def main():
    # process_year_file(2023)
    write_to_db(2023)


if __name__ == "__main__":
    main()
