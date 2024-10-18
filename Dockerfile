# get shiny server and R from the rocker project
FROM ohdsi/broadsea-shiny:1.0.0

# JNJ Specific 
# RUN apt-get install -y ca-certificates
# COPY ZscalerRootCA.crt /root/ZscalerRootCA.crt
# RUN cat /root/ZscalerRootCA.crt >> /etc/ssl/certs/ca-certificates.crt
# COPY ZscalerRootCA.crt /usr/local/share/ca-certificates
# RUN update-ca-certificates

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
RUN R -e 'install.packages(c("remotes", "rJava", "dplyr", "DatabaseConnector", "ResultModelManager", "ggplot2", "plotly", "shinyWidgets", "shiny"), repos="http://cran.rstudio.com/")'

RUN R CMD javareconf

# Set workdir and copy app files
WORKDIR /srv/shiny-server/${APP_NAME}

# copy the app directory into the image
COPY ./app.R .

RUN --mount=type=secret,id=build_github_pat \
        cp /usr/local/lib/R/etc/Renviron /tmp/Renviron \
        && echo "GITHUB_PAT=$(cat /run/secrets/build_github_pat)" >> /usr/local/lib/R/etc/Renviron \
        && R -e "remotes::install_github('OHDSI/ShinyAppBuilder', ref='v3.1.0')" \
	      && R -e "remotes::install_github('OHDSI/OhdsiShinyModules', ref='v3.1.0')" \
        && cp /tmp/Renviron /usr/local/lib/R/etc/Renviron

ENV DATABASECONNECTOR_JAR_FOLDER /root
RUN R -e "DatabaseConnector::downloadJdbcDrivers('postgresql', pathToDriver='/root')"

# run app
EXPOSE 3838
CMD R -e "shiny::runApp('./', host = '0.0.0.0', port = 3838)"
