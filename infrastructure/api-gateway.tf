resource "aws_api_gateway_rest_api" "PlayLambdaApiGateway" {
  name        = "PlayLambdaApiGateway"
  description = "Just playing around with Terraform to create a Lambda API"
}

//resource "aws_api_gateway_stage" "PlayLambdaApiGatewayStage" {
//  stage_name = "${var.environment}"
//  rest_api_id = "${aws_api_gateway_rest_api.PlayLambdaApiGateway.id}"
//  deployment_id = "${aws_api_gateway_deployment.PlayLambdaApiGatewayDeployment.id}"
//  tags = {
//    cost-allocation = "play-${var.environment}"
//    environment = "${var.environment}"
//  }
//}

resource "aws_api_gateway_resource" "Proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.PlayLambdaApiGateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.PlayLambdaApiGateway.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "Proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.PlayLambdaApiGateway.id}"
  resource_id   = "${aws_api_gateway_resource.Proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "PlayLambdaApiLambdaIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.PlayLambdaApiGateway.id}"
  resource_id = "${aws_api_gateway_method.Proxy.resource_id}"
  http_method = "${aws_api_gateway_method.Proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.PlayLambdaApiLambda.invoke_arn}"
}

resource "aws_api_gateway_method" "ProxyRoot" {
  rest_api_id   = "${aws_api_gateway_rest_api.PlayLambdaApiGateway.id}"
  resource_id   = "${aws_api_gateway_rest_api.PlayLambdaApiGateway.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "PlayLambdaApiLambdaIntegrationRoot" {
  rest_api_id = "${aws_api_gateway_rest_api.PlayLambdaApiGateway.id}"
  resource_id = "${aws_api_gateway_method.ProxyRoot.resource_id}"
  http_method = "${aws_api_gateway_method.ProxyRoot.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.PlayLambdaApiLambda.invoke_arn}"
}

resource "aws_api_gateway_deployment" "PlayLambdaApiGatewayDeployment" {
  depends_on = [
    "aws_api_gateway_integration.PlayLambdaApiLambdaIntegration",
    "aws_api_gateway_integration.PlayLambdaApiLambdaIntegrationRoot"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.PlayLambdaApiGateway.id}"
  stage_name  = "${var.environment}"
}

resource "aws_lambda_permission" "GatewayPlayLambdaApiLambdaInvoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.PlayLambdaApiLambda.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.PlayLambdaApiGatewayDeployment.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.PlayLambdaApiGatewayDeployment.invoke_url}"
}