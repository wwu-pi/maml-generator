package de.wwu.maml.maml2md2.rules.view

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import de.wwu.md2.framework.mD2.PackageDefinition
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation

import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*

class Model2View extends Elem2Elem {
	
	public static final String ruleID = "Model->View"
	public static final String ruleIDMD2Model = ruleID + "[MD2Model]"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(de.wwu.maml.dsl.maml.Model))
			.forEach[m |
				// Create view
				val corrV = m.getOrCreateCorrModelElement(ruleIDMD2Model)
				val targetV = corrV.getOrCreateTargetElem(targetPackage.MD2Model) as de.wwu.md2.framework.mD2.MD2Model
				
				val targetPackageView = createTargetElement(targetPackage.packageDefinition) as PackageDefinition
				targetPackageView.pkgName = Maml2md2Transformation.PACKAGE_NAME + ".views"
				targetV.package = targetPackageView
				
				val corrLayerV = m.getOrCreateCorrModelElement(ruleID)
				val targetViewLayer = corrLayerV.getOrCreateTargetElem(targetPackage.view) as de.wwu.md2.framework.mD2.View
				targetV.modelLayer = targetViewLayer
				targetModel.getMD2Resource.contents += targetV
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