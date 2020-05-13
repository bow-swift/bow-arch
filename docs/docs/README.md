---
layout: docs
title: Helios
permalink: /docs/
---

# Helios

[![Build Status](https://travis-ci.org/47deg/helios.svg?branch=master)](https://travis-ci.org/47deg/helios/)
[![Kotlin version badge](https://img.shields.io/badge/kotlin-1.3-blue.svg)](https://kotlinlang.org/docs/reference/whatsnew13.html)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)

**Helios** is a library used to transform `Json` text into a model and vice versa.
It's based on part of the [Jawn Parser](https://github.com/non/jawn) built on `Arrow`,
a Functional companion to Kotlin's Standard Library.

## Why Helios

**Helios** is one of the fastest `Json` parser libraries in `Kotlin`
with the advantage of using the `Arrow` library for functional programming.

## Adding the dependency

**Helios** uses Kotlin version `1.3.31` and `Arrow` version `0.9.0`.

To import the library on `Gradle`, add the following repository and dependencies:

```groovy
repositories {
    maven { url = uri("https://dl.bintray.com/47deg/helios") }
}

dependencies {
    compile "com.47deg:helios-core:0.1.0"
    compile "com.47deg:helios-parser:0.1.0"
    compile "com.47deg:helios-optics:0.1.0"
    kapt "com.47deg:helios-meta:0.1.0"
    kapt "com.47deg:helios-dsl-meta:0.1.0"
}
```

## Quickstart

To see how to start working with **Helios**, lets take a look to the [Quickstart](quickstart/)
