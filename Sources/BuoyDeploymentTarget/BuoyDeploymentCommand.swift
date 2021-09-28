import ArgumentParser
import BuoyDeploymentOption
import DeploymentTargetIoTCommon
import DeploymentTargetIoT
import DeviceDiscovery
import Foundation

struct BuoyDeployCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "deploy",
            abstract: "Buoy Deployment Provider",
            discussion: "Runs the Buoy deployment provider",
            version: "0.0.1"
        )
    }
    
    @Argument(parsing: .unconditionalRemaining, help: "CLI arguments of the web service")
    var webServiceArguments: [String] = []

    @Option
    var types: String = "_workstation._tcp."

    @Option
    var deploymentDir: String = "/usr/deployment"

    @Option
    var dockerComposePath: String
    
    func run() throws {
        let provider = IoTDeploymentProvider(
            searchableTypes: types.split(separator: ",").map(String.init),
            productName: "Buoy",
            packageRootDir: "",
            deploymentDir: "/deployment",
            automaticRedeployment: false,
            webServiceArguments: webServiceArguments,
            input: .dockerCompose(fileURL: URL(fileURLWithPath: dockerComposePath), serviceName: "buoy-web-service", containerName: "buoy-web-service")
        )
        registerSensorPostDiscovery(provider, device: .temperature, sensorType: 0, actionName: "temperature")
        registerSensorPostDiscovery(provider, device: .conductivity, sensorType: 1, actionName: "conductivity")
        registerSensorPostDiscovery(provider, device: .ph, sensorType: 2, actionName: "ph")
        try provider.run()
    }

    func registerSensorPostDiscovery(_ provider: IoTDeploymentProvider, device: DeploymentDevice, sensorType: Int, actionName: String) {
        provider.registerAction(
            scope: .all, 
            action: .docker(
                        DockerDiscoveryAction(
                            identifier: ActionIdentifier(actionName),
                            imageName: "ghcr.io/fa21-collaborative-drone-interactions/buoypostdiscovery:latest",
                            fileUrl: URL(fileURLWithPath: deploymentDir).appendingPathComponent(actionName),
                            options: [
                                .command("\(sensorType) \(actionName)"),
                                .volume(hostDir: "/buoy", containerDir: "/buoy"),
                                .volume(hostDir: deploymentDir, containerDir: "/result"),
                                .credentials(username: "", password: "") // docker image is public
                            ]
                        )
                    ),
            option: DeploymentDeviceMetadata(device)
        )
    }
}
