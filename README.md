# MVI module generation scripts with templates

## How to set up
just run 
```bash
bash ./install.sh <folder_name> ## (android-setup) would be fine
```
it will create folder and move scripts and templates into there
will also add alias for creating core module and feature module for android 
install.sh will provide you how to use in the end.

## Core modules

### Provides comprehensive way of creating core modules that could be shared across application:

- core android module **with** gateway
  - :core:xxx:gateway → common module (pure kotlin)
  - :core:xxx:implementation → android module (contains android deps)

- core android module **without** gateway
  - :core:xxx → android module (contains android deps)

- core common module **with** gateway  
  - :core:xxx:gateway → common module (pure kotlin)
  - :core:xxx:implementation → common module (pure kotlin)

- core common module **without** gateway
    - :core:xxx → common module (pure kotlin)

## Feature modules

### Provides comprehensive way of creating feature modules that could be partially (:data, :domain even :ui if it is called widget*) shared across application:

- feature module **with** data
  - :feature:data --> data module for feature (pure kotlin)
  - :feature:domain --> domain module for feature (pure kotlin)
  - :feature:ui --> ui module for feature (contains android deps)

- feature module **without** data
  - :feature:domain --> domain module for feature (pure kotlin)
  - :feature:ui --> ui module for feature (contains android deps)

## License
Copyright 2026 [droideveloper](https://github.com/droideveloper)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.