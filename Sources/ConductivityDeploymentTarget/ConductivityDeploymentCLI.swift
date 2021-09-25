import ArgumentParser
import DeploymentTargetIoT

@main
struct ConductivityIotDeploymentCLI: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            abstract: "Conductivity Deployment Provider",
            discussion: "Contains Conductivity deployment related commands",
            version: "0.0.1",
            subcommands: [ConductivityDeployCommand.self, KillSessionCommand.self],
            defaultSubcommand: ConductivityDeployCommand.self
        )
    }
}
