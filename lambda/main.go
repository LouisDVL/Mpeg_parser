package main

import (
	"context"
	"fmt"
	"io/ioutil"
	P "spalk/aws/parser"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func handler(ctx context.Context, event events.S3Event) error {
	cfg, err := config.LoadDefaultConfig(ctx)

	if err != nil {
		return err
	}

	s3Client := s3.NewFromConfig(cfg)

	for _, record := range event.Records {
		bucket := record.S3.Bucket.Name
		key := record.S3.Object.Key

		fmt.Printf("Processing file: %s/%s\n", bucket, key)

		getObjectOutput, err := s3Client.GetObject(ctx, &s3.GetObjectInput{
            Bucket: aws.String(bucket),
            Key:    aws.String(key),
        })

		if err != nil {
			return err
		}
		defer getObjectOutput.Body.Close()

		fileBytes, err := ioutil.ReadAll(getObjectOutput.Body)
        if err != nil {
            return err
        }

		P.ParseMPEG(fileBytes)
		// This will copy the file if it is successful if not then it wont be copied to spalk bucket
		// This is just an example of what we can do to prove it can work in a pipeline
		_, err = s3Client.CopyObject(ctx, &s3.CopyObjectInput{
			Bucket: aws.String("spalk"),
			CopySource: aws.String(bucket + "/" + key),
			Key: aws.String(key),
		})

		if err != nil {
			return err
		}
	}

	return nil
}

func main() {
	lambda.Start(handler)
}