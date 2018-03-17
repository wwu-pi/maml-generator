package de.wwu.maml.maml2md2.rules.model

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import de.wwu.md2.framework.mD2.PackageDefinition
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.Maml2md2Transformation

import static extension de.wwu.maml.maml2md2.util.ResourceHelper.*

class Model2Model extends Elem2Elem {
	
	public static final String ruleID = "Model->MD2Model[Model]"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(de.wwu.maml.dsl.maml.Model))
			.forEach[m |
				// Create data model
				val corrM = m.getOrCreateCorrModelElement(ruleID)
				val targetM = corrM.getOrCreateTargetElem(targetPackage.MD2Model) as de.wwu.md2.framework.mD2.MD2Model
				
				val targetPackageModel = createTargetElement(targetPackage.packageDefinition) as PackageDefinition
				targetPackageModel.pkgName = Maml2md2Transformation.PACKAGE_NAME + ".models"
				targetM.package = targetPackageModel
				
				val targetModelLayer = createTargetElement(targetPackage.model) as de.wwu.md2.framework.mD2.Model
				targetM.modelLayer = targetModelLayer
				targetModel.getMD2ModelResource.contents += targetM
			]
	}
	
	override def targetToSource() {
		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
			.forEach[m |
				val corr = m.getOrCreateCorrModelElement(ruleID)
				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
				sourceModel.MAMLResource.contents += source
			]
	}
	
}