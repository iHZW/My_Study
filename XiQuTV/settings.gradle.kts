pluginManagement {
    repositories {
        maven("local-repo")
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven("local-repo")
        google()
        mavenCentral()
    }
}
rootProject.name = "XiQuTV"
include(":app")
