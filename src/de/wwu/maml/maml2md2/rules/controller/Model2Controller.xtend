package de.wwu.maml.maml2md2.rules.controller

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import de.wwu.md2.framework.mD2.PackageDefinition
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation

import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*

class Model2Controller extends Elem2Elem {
	
	public static final String ruleID = "Model->Controller"
	public static final String ruleIDMD2Model = ruleID + "[MD2Model]"
	
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
				targetModel.getMD2ControllerResource.contents += targetC
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