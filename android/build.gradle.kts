allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Note: Build directory configuration removed to use defaults
// If you encounter path issues with spaces, work from C:\Projects\Keneya_muso instead

subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    tasks.withType<org.gradle.api.tasks.compile.JavaCompile> {
        options.compilerArgs.add("-Xlint:-options")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
