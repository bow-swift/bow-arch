---
layout: docs
title: Retrofit integration
permalink: /docs/integrations/retrofit/
---

# Retrofit integration

**Helios** has a [Retrofit](https://square.github.io/retrofit/) integration adding **Helios** to the list of available `converters`.

## Dependency

To start using **Helios** on a *Retrofit* project just add the following dependency:

```groovy
"com.47deg:helios-integrations-retrofit:0.1.0"
```

## Usage

The integration provides an implementation of a *Retrofit* `Converter.Factory` called `HeliosConverterFactory`. 

This converter is constructed using the `create` function 
which needs a list of the `classes` and the class `Encoder` and `Decoder`.

## Example
Let's look at an example of how to add the **Helios'** *Retrofit* integration.

First of all, we need a model for our example:

```kotlin
@json
data class Person(val name: String, val age: Int) {
  companion object
}
```

The `@json` will automatically generate the `Encoder` and `Decoder` for the `Person` model so 
we can use it directly on our `Retrofit.Builder`:

```kotlin:ank:silent
import arrow.core.*
import helios.*
import helios.core.*
import helios.typeclasses.*
import helios.retrofit.HeliosConverterFactory
import helios.retrofit.JsonableEvidence
import retrofit2.Retrofit
//sampleStart
fun getRetrofit(): Retrofit = Retrofit.Builder()
  .addConverterFactory(HeliosConverterFactory.create(
    JsonableEvidence(Person::class, Person.encoder(), Person.decoder())
  ))
  .baseUrl("https://api.github.com/")
  .build()
//sampleEnd
```

There is also an example project available [here](https://github.com/47deg/helios/tree/master/helios-samples/retrofit-sample).
