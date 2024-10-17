# get shiny server and R from the rocker project
FROM ohdsi/broadsea-shiny:1.0.0
# Set an argument for the app name and port
ARG APP_NAME
ARG SHINY_PORT

# Set arguments for the GitHub branch and commit id abbreviation
ARG GIT_BRANCH=unknown
ARG GIT_COMMIT_ID_ABBREV=unknown

# system libraries
# Try to only install system libraries you actually need
# Package Manager is a good resource to help discover system deps
RUN apt-get update && \
    apt-get install -y python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install R packages required
RUN R -e 'install.packages(c("remotes", "rJava", "dplyr"))'

RUN R CMD javareconf

RUN R -e 'remotes::install_github("OHDSI/DatabaseConnector")'
RUN R -e 'remotes::install_github("OHDSI/OhdsiShinyModules")'
RUN R -e 'remotes::install_github("OHDSI/ShinyAppBuilder")'

ENV DATABASECONNECTOR_JAR_FOLDER /root
RUN R -e "DatabaseConnector::downloadJdbcDrivers('postgresql', pathToDriver='/root')"

RUN R -e "install.packages('dplyr', repos='http://cran.rstudio.com/')"
# Set workdir and copy app files
WORKDIR /srv/shiny-server/${APP_NAME}

# copy the app directory into the image
COPY ./app.R .

ARG GITHUB_PAT
ENV GITHUB_PAT=$GITHUB_PAT
RUN R -e 'install.packages(c("ggplot2", "plotly"), repos="http://cran.rstudio.com/")'

# run app
EXPOSE 3838
CMD R -e "shiny::runApp('./', host = '0.0.0.0', port = 3838)"
