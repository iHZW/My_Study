buildscript {
    repositories {
        // 项目内置本地 Maven 仓库（从 ~/.gradle 缓存复制的缺失件），优先命中，避免联网下载
        maven("local-repo")
        google()
        mavenCentral()
    }
    // AGP 7.3.1 传递依赖的 kotlin 1.6.21 本地未缓存，强制替换为已缓存的 1.8.0（API 兼容）
    configurations.all {
        resolutionStrategy {
            force(
                "org.jetbrains.kotlin:kotlin-stdlib:1.8.0",
                "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.0",
                "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.0",
                "org.jetbrains.kotlin:kotlin-reflect:1.8.0"
            )
        }
    }
    dependencies {
        // 使用本地 Gradle 缓存中已有的版本，构建时不联网下载
        classpath("com.android.tools.build:gradle:7.3.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.0")
    }
}
