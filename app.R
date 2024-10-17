library(OhdsiShinyModules)
library(ShinyAppBuilder)
library(dplyr)
options(java.parameters = "-Xss5m")

config <- initializeModuleConfig() %>%
  addModuleConfig(
    createDefaultAboutConfig()
  )  %>%
  addModuleConfig(
    createDefaultDatasourcesConfig()
  )  %>%
  addModuleConfig(
    createDefaultCohortGeneratorConfig()
  ) %>%
  addModuleConfig(
    createDefaultCohortDiagnosticsConfig()
  )  %>%
  addModuleConfig(
    createDefaultCharacterizationConfig()
  ) %>%
  addModuleConfig(
    createDefaultEstimationConfig()
  ) %>%
  addModuleConfig(
    createDefaultPredictionConfig()
  )

resultDatabaseSettings <- createDefaultResultDatabaseSettings(
  schema = 'demotut24'
)

cli::cli_h1("Starting shiny server")
server <- paste0(Sys.getenv("shinydbServer"), "/", Sys.getenv("shinydbDatabase"))
cli::cli_alert_info("Connecting to {server}")
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = server,
  port = Sys.getenv("shinydbPort"),
  user = "shinyproxy",
  password = Sys.getenv("shinydbPw")
)

createShinyApp(config = config,
               connectionDetails = connectionDetails,
               resultDatabaseSettings = resultDatabaseSettings)