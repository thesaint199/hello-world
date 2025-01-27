// infrastructure/bin/infrastructure.ts
#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { InfrastructureStack } from '../lib/infrastructure-stack';
import { Tags } from 'aws-cdk-lib';

const app = new cdk.App();

// Environment configuration
const envUSA = { 
  account: process.env.CDK_DEFAULT_ACCOUNT, 
  region: process.env.CDK_DEFAULT_REGION || 'us-east-1'
};

// Development Stack
const devStack = new InfrastructureStack(app, 'HelloWorld-Dev', {
  env: envUSA,
  stackName: 'hello-world-dev',
  description: 'Development environment for Hello World application',
});

// Add environment tag
Tags.of(devStack).add('Environment', 'Development');
Tags.of(devStack).add('Project', 'HelloWorld');
Tags.of(devStack).add('ManagedBy', 'CDK');

// Production Stack
const prodStack = new InfrastructureStack(app, 'HelloWorld-Prod', {
  env: envUSA,
  stackName: 'hello-world-prod',
  description: 'Production environment for Hello World application',
  // Production-specific props can be added here
  terminationProtection: true,
});

// Add environment tag
Tags.of(prodStack).add('Environment', 'Production');
Tags.of(prodStack).add('Project', 'HelloWorld');
Tags.of(prodStack).add('ManagedBy', 'CDK');

// Staging Stack (Optional)
const stagingStack = new InfrastructureStack(app, 'HelloWorld-Staging', {
  env: envUSA,
  stackName: 'hello-world-staging',
  description: 'Staging environment for Hello World application',
});

// Add environment tag
Tags.of(stagingStack).add('Environment', 'Staging');
Tags.of(stagingStack).add('Project', 'HelloWorld');
Tags.of(stagingStack).add('ManagedBy', 'CDK');

// Add context checks
const requiredContext = [
  'vpcId',
  'availabilityZones',
  'maxAzs',
];

requiredContext.forEach(key => {
  if (!app.node.tryGetContext(key)) {
    console.warn(`Warning: Context value for '${key}' was not provided`);
  }
});

// Security aspects
if (!app.node.tryGetContext('allowedIps')) {
  console.warn('Warning: No IP restrictions specified in context. Using default open access.');
}

// Cost aspects
const costCenter = app.node.tryGetContext('costCenter') || 'undefined';
Tags.of(app).add('CostCenter', costCenter);

app.synth();