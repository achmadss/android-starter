package com.example.domain.di

import com.example.data.di.dataModule
import org.koin.dsl.module

val domainModule = module {
    includes(dataModule)
}