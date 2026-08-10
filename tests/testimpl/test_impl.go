package testimpl

import (
	"context"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/pipes"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	t.Run("VerifyTerraformOutputs", func(t *testing.T) {
		pipeName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "name")
		pipeArn := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "arn")
		pipeId := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "id")
		pipeKmsKeyIdentifier := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "kms_key_identifier")

		require.NotEmpty(t, pipeName, "Pipe name should be set")
		require.NotEmpty(t, pipeArn, "Pipe ARN should be set")
		require.NotEmpty(t, pipeKmsKeyIdentifier, "Pipe KMS key identifier should be set")
		assert.Equal(t, pipeName, pipeId, "Pipe ID should equal pipe name")
		require.Regexp(t, `^arn:aws:pipes:`, pipeArn, "Pipe ARN should be a valid Pipes ARN")
	})

	t.Run("VerifyPipeViaAWSAPI", func(t *testing.T) {
		pipeName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "name")
		desiredState := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "desired_state")
		expectedKmsKeyIdentifier := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "kms_key_identifier")

		cfg, err := config.LoadDefaultConfig(context.Background())
		require.NoError(t, err)

		client := pipes.NewFromConfig(cfg)
		output, err := client.DescribePipe(context.Background(), &pipes.DescribePipeInput{
			Name: &pipeName,
		})
		require.NoError(t, err)
		require.NotNil(t, output)

		assert.Equal(t, pipeName, *output.Name, "Pipe name should match")
		assert.Equal(t, string(desiredState), string(output.DesiredState), "Pipe desired state should match")
		assert.Contains(t, []string{"RUNNING", "STOPPED", "CREATING", "UPDATING"}, string(output.CurrentState), "Pipe should have valid current state")
		assert.Equal(t, expectedKmsKeyIdentifier, aws.ToString(output.KmsKeyIdentifier), "Pipe KMS key identifier should match output")

		expectedEnrichment := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "enrichment")
		assert.Equal(t, expectedEnrichment, aws.ToString(output.Enrichment), "Pipe enrichment should match output")
	})

	t.Run("ExercisePipeWithWrite", func(t *testing.T) {
		sourceArn := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "source")
		targetArn := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "target")
		require.NotEmpty(t, sourceArn, "Source ARN should be set for write test")
		require.NotEmpty(t, targetArn, "Target ARN should be set for write test")
		require.True(t, strings.HasPrefix(sourceArn, "arn:aws:sqs:"), "Source should be SQS ARN for this example")
		require.True(t, strings.HasPrefix(targetArn, "arn:aws:sqs:"), "Target should be SQS ARN for this example")

		// Parse SQS ARN: arn:aws:sqs:region:account:queue-name
		sourceParts := strings.Split(sourceArn, ":")
		targetParts := strings.Split(targetArn, ":")
		require.GreaterOrEqual(t, len(sourceParts), 6, "Source SQS ARN should have at least 6 parts")
		require.GreaterOrEqual(t, len(targetParts), 6, "Target SQS ARN should have at least 6 parts")
		region := sourceParts[3]
		sourceQueueURL := "https://sqs." + region + ".amazonaws.com/" + sourceParts[4] + "/" + sourceParts[5]
		targetQueueURL := "https://sqs." + region + ".amazonaws.com/" + targetParts[4] + "/" + targetParts[5]

		cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
		require.NoError(t, err)

		sqsClient := sqs.NewFromConfig(cfg)

		_, err = sqsClient.SendMessage(context.Background(), &sqs.SendMessageInput{
			QueueUrl:    aws.String(sourceQueueURL),
			MessageBody: aws.String(`{"test":"pipe-exercise"}`),
		})
		require.NoError(t, err, "Should be able to send message to source queue to exercise pipe")

		// Poll target queue until we receive the enriched message (pipe: source -> enrichment -> target)
		var receivedBody string
		for i := 0; i < 30; i++ {
			out, err := sqsClient.ReceiveMessage(context.Background(), &sqs.ReceiveMessageInput{
				QueueUrl:            aws.String(targetQueueURL),
				MaxNumberOfMessages: 1,
				WaitTimeSeconds:     2,
			})
			require.NoError(t, err)
			if len(out.Messages) > 0 {
				receivedBody = aws.ToString(out.Messages[0].Body)
				_, _ = sqsClient.DeleteMessage(context.Background(), &sqs.DeleteMessageInput{
					QueueUrl:      aws.String(targetQueueURL),
					ReceiptHandle: out.Messages[0].ReceiptHandle,
				})
				break
			}
		}
		require.NotEmpty(t, receivedBody, "Expected to receive message at target after pipe processed it")
		assert.Contains(t, receivedBody, `"enriched":true`, "Message should have been enriched by Lambda (enriched field added)")
	})
}

func TestComposableCompleteReadonly(t *testing.T, ctx types.TestContext) {
	t.Run("VerifyTerraformOutputs", func(t *testing.T) {
		pipeName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "name")
		pipeArn := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "arn")

		require.NotEmpty(t, pipeName, "Pipe name should be set")
		require.NotEmpty(t, pipeArn, "Pipe ARN should be set")
		assert.Equal(t, pipeName, terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "id"), "Pipe ID should equal pipe name")
	})

	t.Run("VerifyPipeViaAWSAPIReadonly", func(t *testing.T) {
		pipeName := terraform.OutputContext(t, context.Background(), ctx.TerratestTerraformOptions(), "name")

		cfg, err := config.LoadDefaultConfig(context.Background())
		require.NoError(t, err)

		client := pipes.NewFromConfig(cfg)
		output, err := client.DescribePipe(context.Background(), &pipes.DescribePipeInput{
			Name: &pipeName,
		})
		require.NoError(t, err)
		require.NotNil(t, output)

		assert.Equal(t, pipeName, *output.Name, "Pipe name should match")
		assert.Contains(t, []string{"RUNNING", "STOPPED", "CREATING", "UPDATING"}, string(output.CurrentState), "Pipe should have valid state")
	})
}
