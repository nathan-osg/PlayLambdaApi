const readline = require('readline');
const { exec } = require('child_process');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

let buildNumber = '1';

function execChildProcess(command, opts) {
  console.log('Executing: "%s"', command);
  if (opts) console.log('  with opts: %j', opts);

  return new Promise(function (resolve, reject) {

    function execCallback(err, stdout, stderr) {
      console.log(stdout);
      console.log(stderr);
      if (err) {
        console.log(err);
        reject(err);
      } else {
        resolve();
      }
    }

    exec(command, opts, execCallback);
  });
}

function uploadArtifactToS3() {
  return execChildProcess(`aws s3 cp play-lambda-api.zip s3://playplace-builds/PlayLambdaApi/play-lambda-api-${buildNumber}.zip`)
    .then(() => console.log('Upload complete!'));
}

function updateInfrastructure() {
  return execChildProcess(`terraform apply -var 'build_number=${buildNumber}' -var 'environment=dev' -auto-approve`, { cwd: './infrastructure' })
    .then(() => console.log('Infrastructure update complete!'));
}

rl.question('What build number? ', (answer) => {
  buildNumber = answer;
  rl.close();

  uploadArtifactToS3()
    .then(updateInfrastructure)
    .catch(err => console.error(err));
});


