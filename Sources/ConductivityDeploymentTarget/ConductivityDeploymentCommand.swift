import ArgumentParser
import DeploymentTargetIoTCommon
import DeploymentTargetIoT
import DeviceDiscovery
import Foundation

struct ConductivityDeployCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "deploy",
            abstract: "Conductivity Deployment Provider",
            discussion: "Runs the Conductivity deployment provider",
            version: "0.0.1"
        )
    }
    
    @Argument(parsing: .unconditionalRemaining, help: "CLI arguments of the web service")
    var webServiceArguments: [String] = []
    
    @OptionGroup
    var deploymentOptions: IoTDeploymentOptions
    
    func run() throws {
        // let provider = IoTDeploymentProvider(
        //     searchableTypes: deploymentOptions.types.split(separator: ",").map(String.init),
        //     productName: deploymentOptions.productName,
        //     packageRootDir: deploymentOptions.inputPackageDir,
        //     deploymentDir: deploymentOptions.deploymentDir,
        //     automaticRedeployment: deploymentOptions.automaticRedeploy,
        //     additionalConfiguration: [
        //         .deploymentDirectory: deploymentOptions.deploymentDir
        //     ],
        //     webServiceArguments: webServiceArguments,
        //     //            input: .package
        //     input: .dockerImage("hendesi/master-thesis:latest-arm64")
        // )
        // provider.registerAction(scope: .all, action: .action(LIFXDeviceDiscoveryAction.self), option: DeploymentDeviceMetadata(.lifx))
        // try provider.run()
        print("Deployed")
    }
}
