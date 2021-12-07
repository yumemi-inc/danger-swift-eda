# danger-swift-eda

A danger-swift plug-in to check if the PR matches a specific workflow (e.g. Git-Flow) 

## Install DangerSwiftEda

### SwiftPM (Recommended)

- Add dependency package to your `Package.swift` file which you import danger-swift

    ```swift
    // swift-tools-version:5.5
    ...
    let package = Package(
        ...
        dependencies: [
            ...
            // Danger Plugins
            .package(name: "DangerSwiftEda", url: "https://www.github.com/yumemi-inc/danger-swift-eda.git", from: "0.1.0"),
            ...
        ],
        ...
    )
    ```

- Add the correct import to your `Dangerfile.swift` file

    ```swift
    import DangerSwiftEda
    ```

### Marathon ([Tool Deprecated](https://github.com/JohnSundell/Marathon))

- Just add the dependency import to your `Dangerfile.swift` file like this:

    ```swift
    import DangerSwiftEda // package: https://github.com/yumemi-inc/danger-swift-eda.git
    ```

## Usage

- Setup a configuration based on the workflow you'd like to perform (**currently only Git-Flow supported**)

    ```swift
    let configuration = GitFlowCheckConfiguration(
        // ...
    )
    ```
    
    TIPS: We also have `GitFlowCheckConfiguration.default` if you just want to use default configuration.
    
- Perform the workflow check with `eda.checkPR` method which is available for `DangerDSL` instances

    ```swift
    danger.eda.ckeckPR(workflow: .gitFlow(configuration)) // Assume you have initialized `danger` by code like `let danger = Danger()`
    ```

## Preview

Code above will make danger producing markdown messages like below

> <!--
>   0 failure: 
>   2 warning:  This PR doesn't c..., There's too much ...
>   
>   2 markdown notices
>   DangerID: danger-id-Danger;
> -->
> 
> 
> ## Feature PR Check
> 
> Checking Item | Result
> | ---| --- |
> Base Branch Check | :tada:
> Merge Commit Non-Existence Check | :tada:
> Diff Volume Check | :thinking:
> ChangeLog Modification Check | :thinking:
> 
> <table>
>   <thead>
>     <tr>
>       <th width="50"></th>
>       <th width="100%" data-danger-table="true">Warnings</th>
>     </tr>
>   </thead>
>   <tbody><tr>
>       <td>:warning:</td>
>       <td>This PR doesn't contain any modifications in CHANGELOG.md. Please consider to update the ChangeLog.</td>
>     </tr>
>   
> <tr>
>       <td>:warning:</td>
>       <td>There's too much diff. Please make PRs smaller.</td>
>     </tr>
>   </tbody>
> </table>

