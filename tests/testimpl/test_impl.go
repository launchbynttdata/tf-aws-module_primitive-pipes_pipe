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
		pipeName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")
		pipeArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "arn")
		pipeId := terraform.Output(t, ctx.TerratestTerraformOptions(), "id")

		require.NotEmpty(t, pipeName, "Pipe name should be set")
		require.NotEmpty(t, pipeArn, "Pipe ARN should be set")
		assert.Equal(t, pipeName, pipeId, "Pipe ID should equal pipe name")
		require.Regexp(t, `^arn:aws:pipes:`, pipeArn, "Pipe ARN should be a valid Pipes ARN")
	})

	t.Run("VerifyPipeViaAWSAPI", func(t *testing.T) {
		pipeName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")
		desiredState := terraform.Output(t, ctx.TerratestTerraformOptions(), "desired_state")

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
	})

	t.Run("ExercisePipeWithWrite", func(t *testing.T) {
		sourceArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "source")
		require.NotEmpty(t, sourceArn, "Source ARN should be set for write test")
		require.True(t, strings.HasPrefix(sourceArn, "arn:aws:sqs:"), "Source should be SQS ARN for this example")

		// Parse SQS ARN: arn:aws:sqs:region:account:queue-name
		parts := strings.Split(sourceArn, ":")
		require.GreaterOrEqual(t, len(parts), 6, "SQS ARN should have at least 6 parts")
		region := parts[3]
		accountID := parts[4]
		queueName := parts[5]
		queueURL := "https://sqs." + region + ".amazonaws.com/" + accountID + "/" + queueName

		cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
		require.NoError(t, err)

		sqsClient := sqs.NewFromConfig(cfg)
		_, err = sqsClient.SendMessage(context.Background(), &sqs.SendMessageInput{
			QueueUrl:    aws.String(queueURL),
			MessageBody: aws.String(`{"test":"pipe-exercise"}`),
		})
		require.NoError(t, err, "Should be able to send message to source queue to exercise pipe")
	})
}

func TestComposableCompleteReadonly(t *testing.T, ctx types.TestContext) {
	t.Run("VerifyTerraformOutputs", func(t *testing.T) {
		pipeName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")
		pipeArn := terraform.Output(t, ctx.TerratestTerraformOptions(), "arn")

		require.NotEmpty(t, pipeName, "Pipe name should be set")
		require.NotEmpty(t, pipeArn, "Pipe ARN should be set")
		assert.Equal(t, pipeName, terraform.Output(t, ctx.TerratestTerraformOptions(), "id"), "Pipe ID should equal pipe name")
	})

	t.Run("VerifyPipeViaAWSAPIReadonly", func(t *testing.T) {
		pipeName := terraform.Output(t, ctx.TerratestTerraformOptions(), "name")

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
