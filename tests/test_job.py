from scripts.job import transform_data
from pyspark.sql import SparkSession

def test_transform_data():
    spark = SparkSession.builder.master("local[1]").appName("test").getOrCreate()
    df = transform_data(spark)
    
    assert df.count() == 10
    assert "numero" in df.columns
    assert "cuadrado" in df.columns
    spark.stop()
