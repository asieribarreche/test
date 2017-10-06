#parser resultados UFT xml a formato junit

#Write-Host "Num Args:" $args.Length 
#foreach ($arg in $args)
#{
#  Write-Host "Arg: $arg";
#}

#parametros: 
# ruta xml origen
# ruta xml junit
#$ruta_xml_origen = "C:\Globe\12_Local\Vueling\Fase_2\Funcional_V2\run_results_TC1.xml"
#$ruta_xml_junit = "C:\Globe\12_Local\Vueling\Fase_2\Funcional_V2\reporte_TC1.xml"

param([string]$ruta_xml_origen, [string]$ruta_xml_junit)
Write-Host "Origen: $ruta_xml_origen"
Write-Host "Salida: $ruta_xml_junit"

#inicializacion
$pasado = 0
$fallado = 0
$passed = 0
$failed = 0
#$ruta_xml_origen = "C:\Globe\12_Local\Vueling\Fase_2\Funcional_V2\run_results_TC1.xml"
$nombre_TC = "/Results/ReportNode/Data"
#$ruta_xml_junit = "C:\Globe\12_Local\Vueling\Fase_2\Funcional_V2\reporte_TC1.xml"

[System.Xml.XmlDocument]$file = new-object System.Xml.XmlDocument

#carga del fichero XML salida de UFT
$file.load($ruta_xml_origen)

#ruta al nombre del script UFT
$xml_nombre= $file.SelectNodes($nombre_TC) 
$nombreScript = $xml_nombre.GetElementsByTagName("Name").innertext
#echo "nombre del script: $nombreScript"

#Ruta a los steps - contar cuantos steps tiene el script
$xml_ReportNode= $file.SelectNodes("//ReportNode[@type='Step']")
$total = $xml_ReportNode.Count

#Create a new XML File with config root node
[System.XML.XMLDocument]$oXMLDocument=New-Object System.XML.XMLDocument

# Nuevo nodo "testsuite"
[System.XML.XMLElement]$oXMLRoot=$oXMLDocument.CreateElement("testsuite")

# Append as child to an existing node
$oXMLDocument.appendChild($oXMLRoot)

# Añadir atributos al testsuite: nombre, duracion, total steps
$oXMLRoot.SetAttribute("name",$xml_nombre.GetElementsByTagName("Name").innertext)        
$oXMLRoot.SetAttribute("duration",$xml_nombre.GetElementsByTagName("Duration").innertext)               
$oXMLRoot.SetAttribute("tests",$total)      

#ruta a los results: buscar posibles errores
$failures= $file.SelectNodes("//Result") 
foreach ($resultado in $failures)
{
    if ($resultado.'#text' = "Done")
       {$passed = $passed + 1}
    else
       {$failed = $failed + 1}
}

$oXMLRoot.SetAttribute("failures",$failed)      
         

#recorrer los reportnodes que sean de tipo step
foreach ($ReportNode in $xml_ReportNode) 
{
    if ($ReportNode.type = "Step")
    {
        $tipoNodo = $ReportNode.type
        #echo $ReportNode.GetElementsByTagName("Name")[0].innertext
        #obtencion del dato exacto de pasados y fallidos
        if ($ReportNode.GetElementsByTagName("Result")[0].innertext = "Done")
            {$pasado = $pasado + 1}
            else
            {$fallado = $fallado + 1}
        #creacion de la linea testcase (step), añadimos nombre y duracion
        [System.XML.XMLElement]$oXMLSystem=$oXMLRoot.appendChild($oXMLDocument.CreateElement("testcase"))
        $oXMLSystem.SetAttribute("name",$ReportNode.GetElementsByTagName("Name")[0].innertext)
        $oXMLSystem.SetAttribute("time","0.1")
    } 
}

# Save File
$oXMLDocument.Save($ruta_xml_junit)