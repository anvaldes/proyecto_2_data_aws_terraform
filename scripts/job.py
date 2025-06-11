from pyspark.sql import SparkSession

def transform_data(spark):
    df = spark.range(10).withColumnRenamed("id", "numero")
    df = df.withColumn("cuadrado", df.numero * df.numero)
    return df

if __name__ == "__main__":
    spark = SparkSession.builder.appName("job-simple").getOrCreate()
    df = transform_data(spark)
    df.show()
    df.write.mode("overwrite").parquet("s3://proyecto-1-ml/output/job_simple")
    spark.stop()