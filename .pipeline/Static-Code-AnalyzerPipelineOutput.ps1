# Run UiPath Studio's Workflow Analyzer via command line and pipe results to file and write in the pipeline output info #>

param(
                        $ProjectFilePath="",
                        $ExecutableFilePath="C:\\Users\\sebastian.balan\\AppData\\Local\\Programs\\UiPath\\Studio\\UiPath.Studio.CommandLine.exe",
                        $OutputFilePath="$(Get-Date -Format \'yyyy-MM-dd-HH-mm-ss\')-Workflow-Analysis.json"
                    )
                
                
                    Write-Output "$(Get-Date -Format 'HH:mm:ss') - STARTED - Static Code Analyzer"

                    $Command = "$ExecutableFilePath analyze -p `'$ProjectFilePath`'"
                    Invoke-Expression $Command | Out-File -FilePath $OutputFilePath
                    $rp = Get-Content $OutputFilePath | foreach {$_.replace("#json","")}
                    
                    Set-Content -Path $OutputFilePath -Value $rp
                    #Write-Output $rp
                    $JO = Get-Content $OutputFilePath | ConvertFrom-Json
                    
                    #Write-Output $JO.'056582b5-7ca5-414a-a7fd-2effa9d41931-ErrorSeverity'
                    $totalErros=0
                    
                    
                    $ErrorCode = "Error Code"
                    $ErrorSeverity = "Error Severity"
                    $Description = "Description"
                    $Recommendation = "Recommendation"
                    $FilePath = "File Path"
                    
                    foreach ($ky in $JO.PSObject.Properties)
                    {
                    	if ($ky.Name.EndsWith("ErrorCode"))
                    	{
                    		$ErrorCode = $ky.Value
                    	}
                    	if ($ky.Name.EndsWith("Description"))
                    	{
                    		$Description = $ky.Value
                    	}
                    	if ($ky.Name.EndsWith("FilePath"))
                    	{
                    		$FilePath = $ky.Value
                    	}
                        if ($ky.Name.EndsWith("ErrorSeverity"))
                    	{
                    		$ErrorSeverity = $ky.Value
                    		if ($ErrorSeverity.Equals("Error"))
                    		{
                    			$totalErros++
                    		}
                    	}
                    	if ($ky.Name.EndsWith("Recommendation"))
                    	{
                    		$Recommendation = $ky.Value
                    		if ($ErrorSeverity.Equals("Error"))
                    		{ 
                    			Write-Output "Error code: $ErrorCode, File: $FilePath, $Description, $Recommendation"
                    		}
                    	}
                    }
                    
                    
                    
                    #Write-Output to pipeline
                    
                    Write-Output "$(Get-Date -Format 'HH:mm:ss') - COMPLETED - Static Code Analyzer"
                    
                    #Get-Content $OutputFilePath | ConvertFrom-Json | ConvertTo-Csv | Out-File $CSVFilePath
                    
                    
                    Write-Output "Total Number of Violations = $totalErros"
                    if ($totalErros > 0)
                    {
                    	Exit 1
                    }