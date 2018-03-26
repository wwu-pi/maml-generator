package de.wwu.maml.maml2md2.rules.controller

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import de.wwu.md2.framework.mD2.PackageDefinition
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation

import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*
import de.wwu.md2.framework.mD2.Main

class Model2Controller extends Elem2Elem {
	
	public static final String ruleID = "Model->Controller"
	public static final String ruleIDMD2Model = ruleID + "[MD2Model]"
	public static final String ruleIDremoteConnection = ruleID + "[RemoteConnection]"
	public static final String ruleIDmainBlock = ruleID + "[Main]"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(de.wwu.maml.dsl.maml.Model))
			.forEach[m |
				// Create controller
				val corrC = m.getOrCreateCorrModelElement(ruleIDMD2Model)
				val targetC = corrC.getOrCreateTargetElem(targetPackage.MD2Model) as de.wwu.md2.framework.mD2.MD2Model
				
				val targetPackageController = createTargetElement(targetPackage.packageDefinition) as PackageDefinition
				targetPackageController.pkgName = Maml2md2Transformation.PACKAGE_NAME + ".controllers"
				targetC.package = targetPackageController
				
				val corrLayerC = m.getOrCreateCorrModelElement(ruleID)
				val targetControllerLayer = corrLayerC.getOrCreateTargetElem(targetPackage.controller) as de.wwu.md2.framework.mD2.Controller
				targetC.modelLayer = targetControllerLayer
				targetModel.getMD2Resource.contents += targetC
				
				// Create default remote connection (for workflow manager and remote content providers
				val corrRC = m.getOrCreateCorrModelElement(ruleIDremoteConnection)
				val targetConnection = corrRC.getOrCreateTargetElem(targetPackage.remoteConnection) as de.wwu.md2.framework.mD2.RemoteConnection
				targetConnection.name = "defaultBackend"
				targetConnection.uri = "http://localhost:8080/backend"
				targetControllerLayer.controllerElements.add(targetConnection)
				
				// Create main block
				val corrMain = m.getOrCreateCorrModelElement(ruleIDmainBlock)
				val targetMain = corrMain.getOrCreateTargetElem(targetPackage.main) as Main
				targetMain.appVersion = "1.0"
				targetMain.modelVersion = "1.0"
				targetMain.defaultConnection = targetConnection
				targetMain.workflowManager = targetConnection
				targetControllerLayer.controllerElements.add(targetMain)
			]
	}
	
	override def targetToSource() {
		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
			.forEach[m |
				val corr = m.getOrCreateCorrModelElement(ruleID)
				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
				sourceModel.MAMLResource.contents += source
				println("Correspondence: " + source + " | " + m)
			]
	}
	
}