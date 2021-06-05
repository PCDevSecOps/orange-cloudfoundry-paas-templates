require 'rspec'
require 'tmpdir'
require_relative '../../../lib/upgrade'

describe Upgrade::RootDeployment do
  let(:config_dir) { Dir.mktmpdir }
  let(:root_deployment_name) { "my_root_depl" }
  let(:root_deployment) { described_class.new(root_deployment_name, config_dir) }
  let(:root_deployment_path) { File.join(root_deployment.config_base_dir, root_deployment_name) }
  let(:deployment_1_name) { "depl_1" }
  let(:deployment_1_path) { File.join(root_deployment_path, deployment_1_name) }
  let(:enable_deployment_1_path) { File.join(root_deployment_path, deployment_1_name, "enable-deployment.yml") }
  let(:deployment_2_name) { "depl_2" }
  let(:deployment_2_path) { File.join(root_deployment_path, deployment_2_name) }
  let(:enable_deployment_2_path) { File.join(root_deployment_path, deployment_2_name, "enable-deployment.yml") }
  let(:deployments) { [deployment_1_name, deployment_2_name] }

  after do
    FileUtils.rm_rf(config_dir) unless config_dir.nil?
  end

  context 'when meta-inf does not exist' do
    xit 'generates an error' do
      # allow(File).to receive(:exist?).and_return(false)

      expect {load_meta_inf}.to raise_error(RuntimeError, /meta-inf.yml does not exist/)
    end
  end

  describe "#enable_deployments" do
    let(:enable_deployments) { root_deployment.enable_deployments(deployments) }

    context 'when deployments already exist' do
      it 'successes to run' do
        # expect(root_deployment.name).to eq(root_deployment_name)
        puts root_deployment_path
        enable_deployments
        enable_deployments

        expect(Dir).to exist(deployment_1_path).and exist(deployment_2_path)
        expect(File).to exist(enable_deployment_1_path).and exist(enable_deployment_2_path)
      end
    end
  end

  describe "#disable_deployments" do
    let(:disable_deployments) { root_deployment.disable_deployments(deployments) }

    context 'when deployments do not exist' do
      before do
        disable_deployments
      end

      it 'run successfully' do
        expect(Dir).not_to exist(deployment_1_path)
        expect(Dir).not_to exist(deployment_2_path)
      end
    end
    context 'when deployments exist' do
      let(:enable_deployments) { root_deployment.enable_deployments(deployments) }

      before do
        enable_deployments
      end

      it 'run successfully' do
        disable_deployments
        expect(Dir).to exist(deployment_1_path).and exist(deployment_2_path)
        expect(File).not_to exist(enable_deployment_1_path)
        expect(File).not_to exist(enable_deployment_2_path)
      end
    end

  end


end