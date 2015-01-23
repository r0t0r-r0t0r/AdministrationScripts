function Get-Namespace([string]$namespace = 'root') {

    $innerNamespaces = Get-CimInstance -Namespace $namespace -ClassName __Namespace -ErrorAction Ignore | Select-Object -ExpandProperty Name

    Write-Output $namespace

    foreach($innerNamespace in $innerNamespaces) {
        Get-Namespace "$namespace/$innerNamespace"
    }
}

function Get-PlainClass([string]$Namespace) {
    $classes = Get-CimClass -Namespace $Namespace -ErrorAction Ignore
    foreach ($class in $classes) {
        $methods = $class.CimClassMethods

        foreach ($method in $methods) {
            $parameters = $method.Parameters

            foreach ($parameter in $parameters) {
                $objProps = @{
                    'Namespace' = $Namespace;
                    'Class' = $class.CimClassName;
                    'Method' = $method.Name;
                    'Parameter' = $parameter;
                }
                $obj = New-Object -TypeName PSObject -Property $objProps
                Write-Output $obj
            }
        }
    }
}

function Get-AllPlainClasses {
    $namespaces = Get-Namespace
    foreach ($namespace in $namespaces) {
        $plainClasses = Get-PlainClass $namespace

        Write-Output $plainClasses
    }
}

function Get-FilteredPlainClasses {
    $classes = Get-AllPlainClasses

    foreach ($class in $classes) {
        $Parameter = $class.Parameter
        $Qualifiers = $Parameter.Qualifiers

        $qualifierNames = $Qualifiers | Select-Object -ExpandProperty Name

        $match = ($qualifierNames -contains 'EmbeddedInstance') -and ($qualifierNames -contains 'in') -and ($Parameter.CimType -eq [Microsoft.Management.Infrastructure.CimType]::InstanceArray)

        if ($match -eq $true) {
            Write-Output $class
        }
    }
}

Get-FilteredPlainClasses | Sort-Object -Property Namespace,Class,Method -Unique | Select-Object -Property Namespace,Class,Method
